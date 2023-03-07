# headers

PLAYER_ID="${COOKIES["username"]}"
debug "$PLAYER_ID"

if [[ -z "$PLAYER_ID" ]]; then
  # Create a player id and set it as a cookie
  PLAYER_ID="$(cat /dev/urandom | base64 | head -c 8 | sed 's/[+=\/]//g')"
  printf "%s\r\n" "Set-Cookie: username=${PLAYER_ID}; Path=/"
fi

printf "\r\n"

ROOM_CODE="${REQUEST_PATH##*/}"

htmx_page << EOF
<div hx-sse="connect:/sse/player/${ROOM_CODE}">
    <div hx-trigger="sse:leave, sse:join" hx-get="room/players/${ROOM_CODE}"></div>
</div>
EOF
