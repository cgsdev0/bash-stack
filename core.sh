#!/usr/bin/env bash

declare -A HTTP_HEADERS
declare -A FILE_UPLOADS
declare -A FILE_UPLOAD_TYPES
declare -A FILE_UPLOAD_NAMES
declare -A QUERY_PARAMS
declare -A FORM_DATA
declare -A PATH_VARS
declare -A COOKIES
declare -A SESSION

[[ -f 'config.sh' ]] && source config.sh

debug() {
    printf "%s\n" "$@" 1>&2
}

if [[ "${DEV:-true}" == true ]]; then
  USE_HMR="$(which inotifywait)"

  # disable HMR when using netcat
  if [[ "$TCP_PROVIDER" == "nc" ]]; then
    USE_HMR=""
  fi
fi

header() {
    printf "%s: %s\r\n" "$1" "$2"
}

respond() {
    CODE=$1
    shift
    printf "HTTP/1.1 %s %s\r\n" "$CODE" "$*"
    header Server "bash-stack ${VERSION:-devbuild}"
    [[ ! -z "$SESSION_HEADER_TO_BE_WRITTEN" ]] && \
      printf "%s\n" "$SESSION_HEADER_TO_BE_WRITTEN"

}

end_headers() {
    printf "\r\n"
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

function create_or_resume_session() {
  local KEY
  local VAL
  if [[ -z "${COOKIES[_session]}" ]]; then
    SESSION_ID="$(tr -dc A-Za-z0-9 </dev/urandom | head -c 32 ; echo '')"
    SESSION_HEADER_TO_BE_WRITTEN=$(header Set-Cookie "_session=$SESSION_ID; Path=/; Secure; HttpOnly")
  else
    SESSION_ID=$(echo "${COOKIES[_session]}" | tr -dc A-Za-z0-9)
  fi
  if [[ -f "sessions/$SESSION_ID" ]]; then
    while IFS= read -r line; do
      KEY="$(echo "$line" | cut -f1)"
      VAL="$(echo "$line" | cut -f2-)"
      SESSION["$KEY"]="$VAL"
    done < "sessions/$SESSION_ID"
  fi
}

function save_session() {
  if [[ "${ENABLE_SESSIONS:-false}" != true ]]; then
    debug "Error: You must set ENABLE_SESSIONS=true before calling save_session!"
    return
  fi
  local KEY
  if [[ -z "$SESSION_ID" ]]; then
    return
  fi
  touch "sessions/$SESSION_ID"
  for KEY in ${!SESSION[@]}; do
    printf "%s\t%s\n" "$KEY" "${SESSION[$KEY]}"
  done > "sessions/$SESSION_ID"
}

function _inject_hmr() {
  if [[ -z "$USE_HMR" ]]; then
    return
  fi
  cat <<-EOF
  <div style="display:none" hx-ext="sse" sse-connect="/hmr" sse-swap="none">
    <div hx-trigger="sse:reload" hx-post="/hmr"></div>
  </div>
EOF
}

function htmx_page() {
  if [[ -z "$NO_STYLES" ]]; then
    if [[ -z "$TAILWIND" ]]; then
      STYLE_TEXT='<link rel="stylesheet" href="/static/style.css">'
    else
      STYLE_TEXT='<link rel="stylesheet" href="/static/tailwind.css">'
    fi
  fi
  [[ ${HTTP_HEADERS["hx-request"]} == "true" ]] || [[ "$INTERNAL_REQUEST" == "true" ]] || cat <<-EOF
  <!doctype html>
  <html>
  <head>
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <meta charset="UTF-8">
  ${STYLE_TEXT}
  <script src="https://unpkg.com/htmx.org@1.9.3/dist/htmx.min.js" integrity="sha384-lVb3Rd/Ca0AxaoZg5sACe8FJKF0tnUgR2Kd7ehUOG5GCcROv5uBIZsOqovBAcWua" crossorigin="anonymous"></script>
  <script src="https://unpkg.com/hyperscript.org@0.9.8"></script>
  <script src="https://unpkg.com/htmx.org/dist/ext/sse.js"></script>
  </head>
  <body>
  $(_inject_hmr)
EOF

cat # meow

[[ "$INTERNAL_REQUEST" == "true" ]] || [[ ${HTTP_HEADERS["hx-request"]} == "true" ]] || [[ ! -z "$HIDE_LOGO" ]] || cat <<-EOF
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
    return
  fi
  if [[ ! -d "pubsub/${TOPIC}" ]]; then
    return
  fi
  TEE_ARGS=$(find pubsub/"${TOPIC}" -type p)
  if [[ -z "$TEE_ARGS" ]]; then
    return
  fi
  tee $TEE_ARGS > /dev/null
}

event() {
  printf "event: %s\ndata: %s\n\n" "$@"
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
  if [[ "$1" == "$REQUEST_PATH" ]]; then
    echo "<!-- RECURSION DETECTED -->"
    return
  fi
  local REQUEST_PATH
  local REQUEST_METHOD
  local ROUTE_SCRIPT
  REQUEST_PATH="$1"
  REQUEST_METHOD="GET"
  matchRoute "$REQUEST_PATH"
  INTERNAL_REQUEST=true
  if [[ -f "pages/${ROUTE_SCRIPT}" ]]; then
    result=$(source "pages/${ROUTE_SCRIPT}")
    echo "$result"
  else
    echo "<!-- MISSING COMPONENT: $1 -->"
  fi
}

readonly URI_REGEX='(/[^?#]*)(\?([^#]*))?'

parseHttpRequest() {
  local line

  # Read request line
  read -r REQUEST_METHOD REQUEST_PATH_WITH_PARAMS HTTP_VERSION
  HTTP_VERSION="${HTTP_VERSION%%$'\r'}"
  debug "$REQUEST_METHOD $REQUEST_PATH_WITH_PARAMS $HTTP_VERSION"
  [[ "$REQUEST_PATH_WITH_PARAMS" =~ $URI_REGEX ]]
  REQUEST_PATH="${BASH_REMATCH[1]}"
  REQUEST_QUERY="${BASH_REMATCH[3]}"

  # Parse query parameters
  if [[ ! -z "$REQUEST_QUERY" ]]; then
    while read -r -d '&' line; do
      local VARNAME="${line%%=*}"
      [[ -z "$VARNAME" ]] && continue
      QUERY_PARAMS["$VARNAME"]=$(urldecode "${line#*=}")
    done <<< "${REQUEST_QUERY}&"
  fi

  # Read headers
  while IFS= read -r line; do
    line="${line%%$'\r'}"
    [[ -z "$line" ]] && break
    KEY="${line%%:*}"
    HTTP_HEADERS["${KEY,,}"]="${line#*: }"
  done

  # Parse multipart Form Data
  if [[ ${HTTP_HEADERS["content-type"]} == "multipart/form-data; "* ]]; then
      BOUNDARY="${HTTP_HEADERS["content-type"]}"
      BOUNDARY="${BOUNDARY#*=}"
  fi

  # Read cookies (yum!)
  if [[ ! -z "${HTTP_HEADERS["cookie"]}" ]]; then
    while read -r -d ';' line; do
      COOKIES["${line%%=*}"]=$(urldecode "${line#*=}")
    done <<< "${HTTP_HEADERS[cookie]};"
  fi

  CLEN=${HTTP_HEADERS["content-length"]}

  # Read multipart body
  if [[ ! -z "$BOUNDARY" ]]; then
      matchRoute "$REQUEST_PATH"
      ALLOW_UPLOADS=false
      if directive_test=$(head -1 "pages/${ROUTE_SCRIPT}"); then
        if [[ "$directive_test" == "# allow-uploads" ]]; then
          ALLOW_UPLOADS=true
        fi
      fi
      if [[ "$ALLOW_UPLOADS" != "true" ]]; then
        respond 403 Forbidden
        end_headers
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
              KEY="${PARSED%%:*}"
              MULTIPART_HEADERS["${KEY,,}"]="${PARSED#*: }"
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
                done <<< "${MULTIPART_HEADERS["content-disposition"]};"
                NAME=$(trim_quotes "${DISPOSITIONS[name]}")
                FILENAME=$(trim_quotes "${DISPOSITIONS[filename]}")
                FILE_UPLOADS["$NAME"]="$UPLOAD_TO"
                FILE_UPLOAD_NAMES["$NAME"]="$FILENAME"
                FILE_UPLOAD_TYPES["$NAME"]="${MULTIPART_HEADERS[content-type]}"
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
    [[ ${HTTP_HEADERS["content-type"]} == "application/x-www-form-urlencoded" ]]; then
    while read -r -d '&' line; do
      FORM_DATA["${line%%=*}"]=$(urldecode "${line#*=}")
    done <<< "${REQUEST_BODY}&"
  fi

}

writeHttpResponse() {
  if [[ "$REQUEST_PATH" == "/static/"* ]]; then
    FILE_PATH=".${REQUEST_PATH}"

    if [[ ! -f "$FILE_PATH" ]]; then
      respond 404 Not Found
      end_headers
      return
    fi
    respond 200 OK
    if [[ "$REQUEST_PATH" == *".css" ]]; then
      header Content-Type "text/css"
    else
      header Content-Type "$(file -b --mime-type $FILE_PATH)"
    fi
    end_headers
    cat "$FILE_PATH"
    return
  fi
  matchRoute "$REQUEST_PATH"

  [[ "${ENABLE_SESSIONS:-false}" == "true" ]] && create_or_resume_session

  if [[ ! -z "$USE_HMR" ]] && [[ "$REQUEST_PATH" == "/hmr" ]]; then
    if [[ "$REQUEST_METHOD" == "POST" ]]; then
      respond 204 OK
      header HX-Redirect "${HTTP_HEADERS[hx-current-url]}"
      end_headers
      return
    fi
    respond 200 OK
    header Content-Type "text/event-stream"
    end_headers
    output() {
      killthehmr() {
        kill "$HMR_PID" &> /dev/null
        wait "$HMR_PID" &> /dev/null
        exit 0
      }
      trap 'killthehmr' TERM
      while true; do
        inotifywait -e MODIFY -r pages static &> /dev/null &
        HMR_PID=$!
        wait "$HMR_PID" &> /dev/null
        event "reload"
      done
    }
    output &
    PID=$!


    while IFS= read -r line; do
      :
    done

    kill $PID &>/dev/null
    wait $PID &>/dev/null

    return
  elif [[ -z "$ROUTE_SCRIPT" ]]; then
    debug "404 no match found"
    respond 404 Not Found
    end_headers
    return
  fi


  if directive_test=$(head -1 "pages/${ROUTE_SCRIPT}"); then
    if [[ "$directive_test" == "# sse" ]]; then
      respond 200 OK
      header Content-Type "text/event-stream"
      end_headers
      source "pages/${ROUTE_SCRIPT}"
      TOPIC="$(topic)"
      if [[ -z "$TOPIC" ]]; then
        debug "ERROR: EMPTY TOPIC"
        return
      fi
      SUB_FD=$(subscribe "$TOPIC")
      output() {
        curiosity() {
          kill "$CAT_PID" &> /dev/null
          wait "$CAT_PID" &> /dev/null
          exit 0
        }
        trap 'curiosity' TERM
        while true; do
          cat "$SUB_FD" &
          CAT_PID=$!
          wait "$CAT_PID" &> /dev/null
        done
      }
      output &
      PID=$!

      [[ $(type -t on_open) == function ]] && on_open 1>&2

      while IFS= read -r line; do
        :
      done

      kill "$PID" &>/dev/null
      wait "$PID" &>/dev/null

      unsubscribe "$SUB_FD"
      [[ $(type -t on_close) == function ]] && on_close 1>&2

      return
    elif [[ "$directive_test" == "# headers" ]]; then
      CUSTOM_HEADERS=1
    fi
  fi
  result=$(source "pages/${ROUTE_SCRIPT}")
  CODE=$?
  respond $(decode_result $CODE)
  [[ -z $CUSTOM_HEADERS ]] && header Content-Type "text/html" && end_headers
  printf "%s" "$result"
}

findRoutes() {
  if [[ -z $ROUTES_CACHE ]] || [[ $(stat -c "%s" $ROUTES_CACHE) -eq 0 ]]; then
    cd pages
    find . -type f,l -iname '*.sh' | sed 's@^\./@@' | tee $ROUTES_CACHE
  else
    cat $ROUTES_CACHE
  fi
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

  if [[ "$1" == "/" ]] && [[ -f "pages/index.sh" ]]; then
    ROUTE_SCRIPT="index.sh"
    return
  fi

  local route
  local sanitized

  # for our sanity
  sanitized="${1%%/}"
  while IFS= read -r route; do
    if [[ "/${route%.sh}" == "$sanitized" ]]; then
      ROUTE_SCRIPT="$route"
      return
    fi
  done < <(findPredefinedRoutes)
  while IFS= read -r route; do
    routeRegex="/${route%.sh}"
    routeRegex="^$(echo "$routeRegex" | sed 's@\[[^]]*\]@([^\/]+)@g')$"
    if [[ "$sanitized" =~ $routeRegex ]]; then
      local -a PATH_VALS
      PATH_VALS=("${BASH_REMATCH[@]}")
      ROUTE_SCRIPT="$route"
      [[ "/${route%.sh}" =~ $routeRegex ]]
      for (( i=1; i<${#BASH_REMATCH[@]}; i++ )); do
        local KEY
        KEY="${BASH_REMATCH[$i]}"
        KEY="${KEY//\[}"
        KEY="${KEY//\]}"
        PATH_VARS[$KEY]=${PATH_VALS[$i]}
      done
      return
    fi
  done < <(findDynamicRoutes)
  while IFS= read -r route; do
    routeRegex="/${route%.sh}"
    routeRegex="^${routeRegex//\/\[\[...*\]\]/\(\/.*\)?}$"
    routeRegex="${routeRegex//\//\\/}"
    routeRegex="${routeRegex//\[...*\]/\(.+\)}"
    routeRegex="${routeRegex//\[*\]/\([^\/]+\)}"
    if [[ "$sanitized" =~ $routeRegex ]]; then
      local -a PATH_VALS
      PATH_VALS=("${BASH_REMATCH[@]}")
      ROUTE_SCRIPT="$route"
      [[ "/${route%.sh}" =~ $routeRegex ]]
      for (( i=1; i<${#BASH_REMATCH[@]}; i++ )); do
        local KEY
        local VAL
        KEY="${BASH_REMATCH[$i]}"
        KEY="${KEY//\[}"
        KEY="${KEY//\]}"
        KEY="${KEY//\.}"
        KEY="${KEY//\/}"
        VAL=${PATH_VALS[$i]}
        VAL=${VAL#\/}
        PATH_VARS[$KEY]="$VAL"
      done
      return
    fi
  done < <(findCatchAllRoutes)
}

export -f status_code
export -f component
export -f debug
export -f subscribe
export -f unsubscribe
export -f publish
export -f header
export -f end_headers
export -f event
export -f htmx_page
export -f findPredefinedRoutes
export -f findDynamicRoutes
export -f findCatchAllRoutes
export -f matchRoute
export -f save_session

parseHttpRequest
writeHttpResponse
