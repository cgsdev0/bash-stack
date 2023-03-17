
ROOM_CODE="${REQUEST_PATH##*/}"

htmx_page << EOF
<div hx-sse="connect:/sse/host/${ROOM_CODE}">
  <style>
    .score-controls {
      display: none;
    }
    body {
      background-image: initial;
    }
    #signature {
      display: none;
    }
    .player {
      min-height: initial;
      flex-grow: 1;
    }
    .players {
      margin-top: initial;
    }
    .player-wrapper {
      display: flex;
      flex-grow: 1;
    }
    .player .disconnected {
      color: inherit;
    }
    .player .disconnected::before {
      content: initial;
    }
  </style>
    <div hx-trigger="load, sse:kick, sse:score, sse:leave, sse:join, sse:buzz, sse:unlock" hx-get="/room/players/${ROOM_CODE}" class="players"></div>
</div>
EOF
