# headers

PLAYER_ID="${COOKIES["username"]}"

if [[ -z "$PLAYER_ID" ]]; then
  # Create a player id and set it as a cookie
  PLAYER_ID="$(cat /dev/urandom | base64 | head -c 8 | sed 's/[+=\/]//g')"
  printf "%s\r\n" "Set-Cookie: username=${PLAYER_ID}; Path=/"
fi

printf "\r\n"

ROOM_CODE="${REQUEST_PATH##*/}"

htmx_page << EOF
<div hx-sse="connect:/sse/player/${ROOM_CODE}">
    <div hx-trigger="sse:leave, sse:join, sse:buzz, sse:unlock" hx-get="/room/players/${ROOM_CODE}"></div>
    <form>
    <input type="hidden" name="room_code" value="${ROOM_CODE}" />
    <div hx-sse="swap:unlock">
      <button hx-post="/buzz" hx-sse="swap:buzz" hx-swap="delete">Buzz</button>
    </div>
    </form>
</div>
EOF
