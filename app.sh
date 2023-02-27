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
  route_script=`matchRoute "$REQUEST_PATH"`
  if [[ -z "$route_script" ]]; then
    printf "HTTP/1.1 404 Not Found\r\n\r\n"
    return
  fi

  bash -c "pages/${route_script}"
  if [[ $? == 0 ]]; then
    # for i in "${!HTTP_HEADERS[@]}"; do
    #   debug "%s=%s" "$i" "${HTTP_HEADERS[$i]}"
    # done
    printf "HTTP/1.1 200 OK\r\n\r\n"
  else
    printf "HTTP/1.1 404 Not Found\r\n\r\n"
  fi
}

findRoutes() {
  cd pages
  for i in **/*.sh; do
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
    routeRegex="${routeRegex//\//\\/}"
    routeRegex="^${routeRegex//\[*\]/[^\/]+}$"
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
