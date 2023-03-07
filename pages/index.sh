
htmx_page << EOF
<h1>Jeopardy Buzzer</h1>
<h2>Create Room</h2>
<form hx-post="/create_room" hx-target="body" hx-push-url="true">
<button>Go</button>
</form>
EOF
# <div hx-sse="connect:/sse">
#     <div hx-trigger="sse:message" hx-get="/hi"></div>
# </div>
