#!/usr/bin/env bash

declare -A HTTP_HEADERS
declare -A FORM_DATA
declare -A COOKIES

debug() {
  printf "%s\n" "$@" 1>&2
}

urldecode() {
    # Usage: urldecode "string"
    : "${1//+/ }"
    printf '%b\n' "${_//%/\\x}"
}

function htmx_page() {
[[ ${HTTP_HEADERS["HX-Request"]} == "true" ]] || cat << EOF
  <!doctype html>
  <html>
  <head>
  <script src="https://unpkg.com/htmx.org@1.8.6" integrity="sha384-Bj8qm/6B+71E6FQSySofJOUjA/gq330vEqjFx9LakWybUySyI1IQHwPtbTU7bNwx" crossorigin="anonymous"></script>
  <script src="https://unpkg.com/hyperscript.org@0.9.8"></script>
  </head>
  <body>
EOF

cat

[[ ${HTTP_HEADERS["HX-Request"]} == "true" ]] || cat << EOF
</body>
</html>
EOF
}
# usage: subscribe [topic]
# returns: handle of a fifo (via stdout)
function subscribe() {
  local TOPIC
  TOPIC="$1"
  if [[ -z "$TOPIC" ]]; then
    debug "ATTEMPTED TO SUBSCRIBE ON EMPTY TOPIC"
    return
  fi
  debug "NEW SUBSCRIBER ON $TOPIC"
  mkdir -p pubsub/"${TOPIC}"
  tmppipe=$(mktemp -up pubsub/"${TOPIC}")
  mkfifo -m 600 "$tmppipe"
  echo "$tmppipe"
}

function unsubscribe() {
  local TOPIC
  TOPIC="$1"
  if [[ "$TOPIC" != "pubsub/"* ]]; then
    debug "FAILED TO UNSUBSCRIBE"
    return
  fi
  rm -f "$TOPIC"
  debug "UNSUBSCRIBED FROM ${TOPIC%/*}"
}

function publish() {
  local TOPIC
  local line
  TOPIC="$1"
  if [[ -z "$TOPIC" ]]; then
    debug "ATTEMPTED TO PUBLISH ON EMPTY TOPIC"
    return
  fi
  if [[ ! -d "pubsub/${TOPIC}" ]]; then
    debug "NO SUBSCRIBERS ON ${TOPIC}"
    return
  fi
  while IFS= read -r line; do
  # TODO: use -exec on find directly
  find pubsub/"${TOPIC}" -type p \
    | xargs -I {} bash -c "printf '%s\n' '$line' > {}"
  done
}

export -f debug
export -f subscribe
export -f unsubscribe
export -f publish
export -f htmx_page

parseHttpRequest() {
  local line

  # Read request line
  read -r REQUEST_METHOD REQUEST_PATH HTTP_VERSION
  HTTP_VERSION="${HTTP_VERSION%%$'\r'}"
  debug "$REQUEST_METHOD $REQUEST_PATH $HTTP_VERSION"

  # Read headers
  while IFS= read -r line; do
    line="${line%%$'\r'}"
    [[ -z "$line" ]] && break
    HTTP_HEADERS["${line%%:*}"]="${line#*: }"
    # debug "$line"
  done

  # Read body
  CLEN=${HTTP_HEADERS["Content-Length"]}
  [[ "$CLEN" =~ ^[0-9]+$ ]] && \
    test $CLEN -gt 0 && read -N $CLEN REQUEST_BODY;
  # Parse Form Data
  if [[ ${HTTP_HEADERS["Content-Type"]} == "application/x-www-form-urlencoded" ]]; then
    while read -r -d '&' line; do
      FORM_DATA["${line%%=*}"]=$(urldecode "${line#*=}")
    done << EOF
${REQUEST_BODY}&
EOF
  fi

  if [[ ! -z "${HTTP_HEADERS["Cookie"]}" ]]; then
    while read -r -d ';' line; do
      COOKIES["${line%%=*}"]=$(urldecode "${line#*=}")
    done << EOF
${HTTP_HEADERS["Cookie"]};
EOF
  fi
}

writeHttpResponse() {
  route_script=`matchRoute "$REQUEST_PATH"`
  if [[ -z "$route_script" ]]; then
    debug "404 no match found"
    printf "%s\r\n" "HTTP/1.1 404 Not Found"
    printf "%s\r\n" ""
    return
  fi

  debug "pages/${route_script}"
  if directive_test=$(head -1 "pages/${route_script}"); then
    if [[ "$directive_test" == "# sse" ]]; then
      printf "%s\r\n" "HTTP/1.1 200 OK"
      printf "%s\r\n" "Content-Type: text/event-stream"
      printf "%s\r\n" ""
      source "pages/${route_script}"
      return
    elif [[ "$directive_test" == "# headers" ]]; then
      CUSTOM_HEADERS=1
    fi
  fi
  result=$(source "pages/${route_script}")
  if [[ $? == 0 ]]; then
    # for i in "${!HTTP_HEADERS[@]}"; do
    #   debug "%s=%s" "$i" "${HTTP_HEADERS[$i]}"
    # done
    printf "%s\r\n" "HTTP/1.1 200 OK"

    [[ -z $CUSTOM_HEADERS ]] && printf "%s\r\n" ""
    printf "%s" "$result"
  else
    printf "%s\r\n" "HTTP/1.1 404 Not Found"
    printf "%s\r\n" ""
  fi
}

findRoutes() {
  cd pages
  for i in $(find . -type f -iname '*.sh' \
    | sed 's@^\./@@'); do
    echo $i;
  done
}

findPredefinedRoutes() {
  findRoutes | grep -v '\['
}

findDynamicRoutes() {
  findRoutes | grep '\[[^\.]' | grep -v '\[\.\.\.'
}

findCatchAllRoutes() {
  findRoutes | grep '\[\.\.\.'
}

matchRoute() {

  if [[ "$1" == "/" ]]; then
    echo "index.sh"
    return
  fi

  local route
  local sanitized

  # for our sanity
  sanitized="${1%%/}"
  findPredefinedRoutes | while IFS= read -r route; do
    [[ "/${route%.sh}" == "$sanitized" ]] && echo "$route" && return
  done
  findDynamicRoutes | while IFS= read -r route; do
    routeRegex="/${route%.sh}"
    # routeRegex="${routeRegex//\//\\/}"
    routeRegex="^$(echo "$routeRegex" | sed 's@\[[^]]*\]@[^\/]+@g')$"
    # debug "THE REGEX IS '$routeRegex'"
    [[ "$sanitized" =~ $routeRegex ]] && echo "$route" && return
  done
  findCatchAllRoutes | while IFS= read -r route; do
    routeRegex="/${route%.sh}"
    routeRegex="^${routeRegex//\/\[\[...*\]\]/.*}$"
    routeRegex="${routeRegex//\//\\/}"
    routeRegex="^${routeRegex//\[...*\]/.+}$"
    routeRegex="^${routeRegex//\[*\]/[^\/]+}$"
    [[ "$sanitized" =~ $routeRegex ]] && echo "$route" && return
  done
}

parseHttpRequest
writeHttpResponse
