#!/usr/bin/env bash

declare -A HTTP_HEADERS
declare -A FILE_UPLOADS
declare -A FILE_UPLOAD_TYPES
declare -A FILE_UPLOAD_NAMES
declare -A QUERY_PARAMS
declare -A FORM_DATA
declare -A COOKIES

debug() {
  printf "%s\n" "$@" 1>&2
}

trim_quotes() {
    # Usage: trim_quotes "string"
    : "${1//\'}"
    printf '%s\n' "${_//\"}"
}

urlencode() {
    # Usage: urlencode "string"
    local LC_ALL=C
    for (( i = 0; i < ${#1}; i++ )); do
        : "${1:i:1}"
        case "$_" in
            [a-zA-Z0-9.~_-])
                printf '%s' "$_"
            ;;

            *)
                printf '%%%02X' "'$_"
            ;;
        esac
    done
    printf '\n'
}

urldecode() {
    # Usage: urldecode "string"
    : "${1//+/ }"
    printf '%b\n' "${_//%/\\x}"
}

function htmx_page() {
  if [[ -z "$NO_STYLES" ]]; then
    STYLE_TEXT='<link rel="stylesheet" href="/static/style.css">'
  fi
  [[ ${HTTP_HEADERS["HX-Request"]} == "true" ]] || [[ "$INTERNAL_REQUEST" == "true" ]] || cat << EOF
  <!doctype html>
  <html>
  <head>
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  ${STYLE_TEXT}
  <script src="https://unpkg.com/htmx.org@1.9.3" integrity="sha384-lVb3Rd/Ca0AxaoZg5sACe8FJKF0tnUgR2Kd7ehUOG5GCcROv5uBIZsOqovBAcWua" crossorigin="anonymous"></script>
  <script src="https://unpkg.com/hyperscript.org@0.9.8"></script>
  <script src="https://unpkg.com/htmx.org/dist/ext/sse.js"></script>
  </head>
  <body>
EOF

cat # meow

[[ "$INTERNAL_REQUEST" == "true" ]] || [[ ${HTTP_HEADERS["HX-Request"]} == "true" ]] || [[ ! -z "$HIDE_LOGO" ]] || cat << EOF
<div id="signature">
<a href="https://github.com/cgsdev0/bash-stack" target="_blank">
<svg xmlns="http://www.w3.org/2000/svg" width="224" height="256" viewBox="0 0 224 256"><path fill="#FFF" d="M207.953 52.162L127.317 4.287a30.372 30.372 0 0 0-31.114 0L15.55 52.162A32.165 32.165 0 0 0 0 79.869v95.734a32.165 32.165 0 0 0 15.55 27.691l80.636 47.859a30.388 30.388 0 0 0 31.115 0l80.636-47.859a32.165 32.165 0 0 0 15.566-27.707V79.869a32.165 32.165 0 0 0-15.55-27.707Z"/><path fill="#2F3A3E" d="m208.412 52.277l-80.814-47.98a30.439 30.439 0 0 0-31.184 0l-80.83 47.98A32.236 32.236 0 0 0 0 80.045v95.945a32.236 32.236 0 0 0 15.584 27.752l80.814 47.964a30.455 30.455 0 0 0 31.183 0l80.814-47.964a32.236 32.236 0 0 0 15.6-27.769V80.045a32.236 32.236 0 0 0-15.583-27.768ZM99.23 246.803l-80.814-47.964A26.604 26.604 0 0 1 5.6 175.989V80.046a26.588 26.588 0 0 1 12.816-22.849L99.23 9.216a24.92 24.92 0 0 1 25.536 0l80.749 47.98a26.426 26.426 0 0 1 12.412 18.48c-2.687-5.712-8.723-7.282-15.762-3.236l-76.396 47.316c-9.531 5.551-16.554 11.814-16.57 23.303v94.213c0 6.877 2.767 11.327 7.039 12.638a24.759 24.759 0 0 1-4.24.405a25.034 25.034 0 0 1-12.768-3.512Z"/><path fill="#3AB14A" d="m187.007 185.06l-20.086 12.013a1.47 1.47 0 0 0-.92 1.308v5.28c0 .646.435.904.968.597l20.394-12.4a1.616 1.616 0 0 0 .613-1.615v-4.634c-.016-.598-.484-.856-.969-.55Z"/><path fill="#FFF" d="M144.263 140.832c.646-.323 1.179 0 1.195.92l.064 7.008a12.917 12.917 0 0 1 7.718-.937c.501.13.71.808.517 1.615l-1.534 6.152a2.648 2.648 0 0 1-.694 1.227a1.615 1.615 0 0 1-.404.29a.92.92 0 0 1-.597.098a10.237 10.237 0 0 0-7.444 1.194a9.349 9.349 0 0 0-5.506 8.284c0 3.229 1.615 4.117 7.25 4.214c7.444.13 10.673 3.375 10.754 10.883a26.69 26.69 0 0 1-9.882 20.135l.13 6.878a2.519 2.519 0 0 1-1.18 2.1l-4.068 2.34c-.646.323-1.18 0-1.195-.904v-6.765c-3.488 1.453-7.024 1.792-9.285.888c-.42-.162-.613-.791-.436-1.518l1.47-6.216a2.6 2.6 0 0 1 .726-1.292c.115-.11.246-.203.388-.275a.807.807 0 0 1 .662 0c2.878.78 5.948.392 8.541-1.081a11.173 11.173 0 0 0 6.314-9.688c0-3.488-1.922-4.941-6.459-4.974c-5.861 0-11.303-1.13-11.416-9.688a25.027 25.027 0 0 1 9.462-19.15l-.29-7.04a2.503 2.503 0 0 1 1.178-2.13l4.021-2.568Z"/></svg>
<span>Powered by bash</span></a>
</div>
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
    find pubsub/"${TOPIC}" -type p \
      | xargs -P 4 -I {} bash -c "printf '%s\n' '$line' > {}"
  done
}

# encode result
# can encode the following status codes as unix return codes:
# 200-263
# 300-363
# 400-463
# 500-563
function status_code() {
  A=${1:0:1}
  B=${1:1:2}
  echo $(( ((A - 2) << 6) + B ))
}

function decode_result() {
  ENCODED=${1}
  printf "%d%02d" $(((ENCODED >> 6) + 2)) $(( ENCODED & 63 ))
}

function component() {
  local REQUEST_PATH
  local REQUEST_METHOD
  REQUEST_PATH="$1"
  REQUEST_METHOD="GET"
  route_script=`matchRoute "$REQUEST_PATH"`
  INTERNAL_REQUEST=true
  result=$(source "pages/${route_script}")
  echo "$result"
}

export -f status_code
export -f component
export -f debug
export -f subscribe
export -f unsubscribe
export -f publish
export -f htmx_page

readonly URI_REGEX='(/[^?#]*)(\?([^#]*))?'

parseHttpRequest() {
  local line

  # Read request line
  read -r REQUEST_METHOD REQUEST_PATH_WITH_PARAMS HTTP_VERSION
  HTTP_VERSION="${HTTP_VERSION%%$'\r'}"
  debug "$REQUEST_METHOD $REQUEST_PATH_WITH_PARAMS $HTTP_VERSION"
  REQUEST_PATH=$([[ "$REQUEST_PATH_WITH_PARAMS" =~ $URI_REGEX ]] && echo "${BASH_REMATCH[1]}")
  REQUEST_QUERY=$([[ "$REQUEST_PATH_WITH_PARAMS" =~ $URI_REGEX ]] && echo "${BASH_REMATCH[3]}")

  # Parse query parameters
  if [[ ! -z "$REQUEST_QUERY" ]]; then
    while read -r -d '&' line; do
      QUERY_PARAMS["${line%%=*}"]=$(urldecode "${line#*=}")
    done << EOF
${REQUEST_QUERY}&
EOF
  fi

  # Read headers
  while IFS= read -r line; do
    line="${line%%$'\r'}"
    [[ -z "$line" ]] && break
    HTTP_HEADERS["${line%%:*}"]="${line#*: }"
    # debug "$line"
  done

  # Parse multipart Form Data
  if [[ ${HTTP_HEADERS["Content-Type"]} == "multipart/form-data; "* ]]; then
      BOUNDARY="${HTTP_HEADERS["Content-Type"]}"
      BOUNDARY="${BOUNDARY#*=}"
  fi

  # Read cookies (yum!)
  if [[ ! -z "${HTTP_HEADERS["Cookie"]}" ]]; then
    while read -r -d ';' line; do
      COOKIES["${line%%=*}"]=$(urldecode "${line#*=}")
    done << EOF
${HTTP_HEADERS["Cookie"]};
EOF
  fi

  CLEN=${HTTP_HEADERS["Content-Length"]}

  # Read multipart body
  if [[ ! -z "$BOUNDARY" ]]; then
      route_script=`matchRoute "$REQUEST_PATH"`
      ALLOW_UPLOADS=false
      if directive_test=$(head -1 "pages/${route_script}"); then
        if [[ "$directive_test" == "# allow-uploads" ]]; then
          ALLOW_UPLOADS=true
        fi
      fi
      if [[ "$ALLOW_UPLOADS" != "true" ]]; then
        printf "%s\r\n" "HTTP/1.1 403 Forbidden"
        printf "%s\r\n" "Server: bash lol"
        printf "%s\r\n" ""
        return
      fi
      state="start"
      reader="reading"
      local -A MULTIPART_HEADERS
      local -A DISPOSITIONS
      while read -n2 byte; do
        # we have to implement our own readline because of reasons
        if [[ "$reader" == "reading" ]]; then
          if [[ "$byte" == "0a" ]]; then
            reader="flushing-newline"
          elif [[ "$byte" == "00" ]]; then
            reader="flushing-null"
          else
            line="${line}${byte}"
          fi
        fi
        if [[ "$reader" == "flushing"* ]]; then
          PARSED="$(echo -n $line | xxd -r -p)"
          if [[ "$state" == "start" ]] && [[ "$PARSED" == "--$BOUNDARY"* ]]; then
            state="headers"
            MULTIPART_HEADERS=()
            DISPOSITIONS=()
          elif [[ "$state" == "headers" ]]; then
            PARSED="${PARSED%%$'\r'}"
            if [[ -z "$PARSED" ]]; then
              UPLOAD_TO=$(mktemp -p uploads)
              state="body"
            else
              MULTIPART_HEADERS["${PARSED%%:*}"]="${PARSED#*: }"
            fi
          elif [[ "$state" == "body" ]]; then
            if [[ "$reader" == "flushing-null" ]]; then
              # this is a null char
              echo -n "${line}00" | xxd -r -p >> "$UPLOAD_TO"
            else
              # this is a newline char
              if [[ "$PARSED" == "--$BOUNDARY"* ]]; then
                while read -r -d ';' line; do
                  DISPOSITIONS["${line%%=*}"]=$(urldecode "${line#*=}")
                done << EOF
${MULTIPART_HEADERS["Content-Disposition"]};
EOF
                NAME=$(trim_quotes "${DISPOSITIONS[name]}")
                FILENAME=$(trim_quotes "${DISPOSITIONS[filename]}")
                FILE_UPLOADS["$NAME"]="$UPLOAD_TO"
                FILE_UPLOAD_NAMES["$NAME"]="$FILENAME"
                FILE_UPLOAD_TYPES["$NAME"]="${MULTIPART_HEADERS[Content-Type]}"
                MULTIPART_HEADERS=()
                DISPOSITIONS=()
                state="headers"
                if [[ "$PARSED" == "--$BOUNDARY--"* ]]; then
                  # i dont know how, but we made it out alive
                  break
                fi
              else
                echo -n "${line}0a" | xxd -r -p >> "$UPLOAD_TO"
              fi
            fi
          fi
          reader="reading"
          line=''
        fi
        # wheeeeeeeeeeeeeeeee
      done < <(stdbuf -o0 -i0 hexdump -v -e '/1 "%02x"' -n $CLEN)
  else
    # Read body
    [[ "$CLEN" =~ ^[0-9]+$ ]] && \
      test $CLEN -gt 0 && read -rN $CLEN REQUEST_BODY;
  fi
  # Parse Form Data
  if [[ ! -z "$REQUEST_BODY" ]] && \
    [[ ${HTTP_HEADERS["Content-Type"]} == "application/x-www-form-urlencoded" ]]; then
    while read -r -d '&' line; do
      FORM_DATA["${line%%=*}"]=$(urldecode "${line#*=}")
    done << EOF
${REQUEST_BODY}&
EOF
  fi

}

writeHttpResponse() {
  if [[ "$REQUEST_PATH" == "/static/"* ]]; then
    FILE_PATH=".${REQUEST_PATH}"

    if [[ ! -f "$FILE_PATH" ]]; then
      printf "%s\r\n" "HTTP/1.1 404 Not Found"
      printf "%s\r\n" "Server: bash lol"
      printf "%s\r\n" ""
      return
    fi
    printf "%s\r\n" "HTTP/1.1 200 OK"
    printf "%s\r\n" "Server: bash lol"
    if [[ "$REQUEST_PATH" == *".css" ]]; then
      printf "%s\r\n" "Content-Type: text/css"
    else
      printf "%s\r\n" "Content-Type: $(file -b --mime-type $FILE_PATH)"
    fi
    printf "%s\r\n" ""
    cat "$FILE_PATH"
    return
  fi
  route_script=`matchRoute "$REQUEST_PATH"`
  if [[ -z "$route_script" ]]; then
    debug "404 no match found"
    printf "%s\r\n" "HTTP/1.1 404 Not Found"
    printf "%s\r\n" "Server: bash lol"
    printf "%s\r\n" ""
    return
  fi

  if directive_test=$(head -1 "pages/${route_script}"); then
    if [[ "$directive_test" == "# sse" ]]; then
      printf "%s\r\n" "HTTP/1.1 200 OK"
      printf "%s\r\n" "Server: bash lol"
      printf "%s\r\n" "Content-Type: text/event-stream"
      printf "%s\r\n" ""
      source "pages/${route_script}"
      return
    elif [[ "$directive_test" == "# headers" ]]; then
      CUSTOM_HEADERS=1
    fi
  fi
  result=$(source "pages/${route_script}")
  CODE=$?
  if [[ "$CODE" -lt 64 ]]; then
    # for i in "${!HTTP_HEADERS[@]}"; do
    #   debug "%s=%s" "$i" "${HTTP_HEADERS[$i]}"
    # done
    printf "%s\r\n" "HTTP/1.1 200 OK"
    printf "%s\r\n" "Server: bash lol"
    [[ -z $CUSTOM_HEADERS ]] && printf "%s\r\n" "Content-Type: text/html"

    [[ -z $CUSTOM_HEADERS ]] && printf "%s\r\n" ""
    printf "%s" "$result"
  else
    printf "%s\r\n" "HTTP/1.1 $(decode_result $CODE)"
    printf "%s\r\n" "Server: bash lol"
    printf "%s\r\n" ""
    printf "%s" "$result"
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
    routeRegex="^$(echo "$routeRegex" | sed 's@\[[^]]*\]@[^\/]+@g')$"
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

export -f findPredefinedRoutes
export -f findDynamicRoutes
export -f findCatchAllRoutes
export -f matchRoute

parseHttpRequest
writeHttpResponse
