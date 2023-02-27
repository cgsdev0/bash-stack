#!/usr/bin/env bash

declare -A HTTP_HEADERS

debug() {
  printf "$@" 1>&2
  printf "\n" 1>&2
}
parseHttpRequest() {
  local line

  # Read request line
  read -r REQUEST_METHOD REQUEST_PATH HTTP_VERSION
  HTTP_VERSION="${HTTP_VERSION%%$'\r'}"

  # Read headers
  while IFS= read -r line; do
    line="${line%%$'\r'}"
    [[ -z "$line" ]] && return
    HTTP_HEADERS["${line%%:*}"]="${line#*: }"
  done
}

writeHttpResponse() {
  if [[ "$REQUEST_PATH" == "/" ]]; then
    # for i in "${!HTTP_HEADERS[@]}"; do 
    #   debug "%s=%s" "$i" "${HTTP_HEADERS[$i]}"
    # done
    printf "HTTP/1.1 200 OK\r\n\r\n"
  else
    printf "HTTP/1.1 404 Not Found\r\n\r\n"
  fi
}

parseHttpRequest
writeHttpResponse
