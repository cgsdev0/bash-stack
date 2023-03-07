
ROOM_CODE="${REQUEST_PATH##*/}"

htmx_page << EOF
<pre>${FORM_DATA["password"]}</pre>

<div hx-sse="connect:/sse/host/${ROOM_CODE}">
    <div hx-trigger="sse:leave, sse:join, sse:unlock, sse:buzz, load" hx-get="/room/players/${ROOM_CODE}"></div>
    <form>
    <input type="hidden" name="room_code" value="${ROOM_CODE}" />
    <button hx-post="/reset" hx-sse="swap:buzz" >Reset</button>
    </form>
</div>
EOF
