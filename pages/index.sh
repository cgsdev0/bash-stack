
htmx_page << EOF
<div class="container">
<h1>Jeopardy Buzzer</h1>
<h2>Create Room</h2>
<form hx-post="/create_room" hx-target="body" hx-push-url="true">
<button>Go</button>
</form>
</div>
EOF
