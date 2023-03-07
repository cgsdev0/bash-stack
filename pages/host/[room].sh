
ROOM_CODE="${REQUEST_PATH##*/}"

htmx_page << EOF
<pre>${FORM_DATA["password"]}</pre>

<div hx-sse="connect:/sse/host/${ROOM_CODE}">
    <div hx-trigger="sse:leave, sse:join" hx-get="room/players/${ROOM_CODE}"></div>
</div>
EOF
