
PLAYER_ID="${COOKIES["username"]}"

if [[ -z "$PLAYER_ID" ]]; then
  htmx_page << EOF
<div class="container">
<h1>Jeopardy Buzzer</h1>
<form hx-post="/login">
<input type="text" name="username" placeholder="Enter your name" autocomplete="off" />
<button type="submit">Join Room</button>
</form>
</div>
EOF
  return
  # Create a player id and set it as a cookie
  # PLAYER_ID="$(cat /dev/urandom | base64 | head -c 8 | sed 's/[+=\/]//g')"
  # printf "%s\r\n" "Set-Cookie: username=${PLAYER_ID}; Path=/"
  # printf "\r\n"
fi


ROOM_CODE="${REQUEST_PATH##*/}"

htmx_page << EOF
<div hx-sse="connect:/sse/player/${ROOM_CODE}">
  <style>
    .score-controls {
      display: none;
    }
  </style>
    <div hx-trigger="sse:score, sse:leave, sse:join, sse:buzz, sse:unlock" hx-get="/room/players/${ROOM_CODE}" class="players"></div>
    <form>
    <input type="hidden" name="room_code" value="${ROOM_CODE}" />
    <div class="button-container">
      <button hx-post="/buzz"></button>
    </div>
    </form>
</div>
<a class="footer-link" href="#" hx-post="/login">Change Username</a>
EOF
