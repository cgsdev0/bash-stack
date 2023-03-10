
ROOM_CODE="${REQUEST_PATH##*/}"

htmx_page << EOF

<div hx-sse="connect:/sse/host/${ROOM_CODE}">
    <div hx-trigger="sse:leave, sse:join, sse:unlock, sse:buzz, load" hx-get="/room/players/${ROOM_CODE}" class="players"></div>
    <form>
    <input type="hidden" name="room_code" value="${ROOM_CODE}" />
    <div class="button-container">
      <button hx-post="/reset" hx-sse="swap:buzz">Reset</button>
    </div>
    </form>
</div>
<form class="footer-link copy">
  <input type="text" value="http://${HTTP_HEADERS["Host"]}/player/${ROOM_CODE}">
  <button type="button">Copy</button>
</form>
<script type="text/javascript">
(function() {
  var copyButton = document.querySelector('.copy button');
  var copyInput = document.querySelector('.copy input');
  copyButton.addEventListener('click', function(e) {
    e.preventDefault();
    var text = copyInput.select();
    document.execCommand('copy');
  });

  copyInput.addEventListener('click', function() {
    this.select();
  });
})();
</script>
EOF
