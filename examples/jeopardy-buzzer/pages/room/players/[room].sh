
ROOM_CODE="${REQUEST_PATH##*/}"

touch "data/room-$(basename ${ROOM_CODE})"
SCORE_FILE="data/scores-$(basename ${ROOM_CODE})"
PLAYERS=$(cat "data/room-$(basename ${ROOM_CODE})")

while IFS= read -r player; do
  [[ -z "$player" ]] && break;
  LOOPED=true
  if [[ -f "data/buzzed-$(basename ${ROOM_CODE})" ]]; then
    BUZZED=$(cat "data/buzzed-$(basename ${ROOM_CODE})")
  fi

  read username disconnected << EOF
$player
EOF

  SCORE=$(set -o pipefail; (grep -P "$username\t" "$SCORE_FILE" | cut -f2) || echo 0);
  BUZZED_CLASS=$([[ "$BUZZED" == "$username" ]] && echo " buzzed")
  RED_CLASS=$([[ "$SCORE" -lt "0" ]] && echo " red")
  DC_CLASS=$([[ -z "$disconnected" ]] || echo " disconnected")
  KICK=$([[ -z "$disconnected" ]] || echo " hx-post='/kick/${username}' hx-trigger='click' hx-swap='none'")
  echo """
  <div class='player-wrapper'>
    <div class='player${BUZZED_CLASS}'>
<form>
<input type='hidden' value='${ROOM_CODE}' name='room_code' />
      <div class='username${DC_CLASS}'${KICK}>${username}</div>
      </form>
      <div id='score-for-${username}' class='score${RED_CLASS}'>${SCORE}</div>
    </div>
    <form hx-post='/score' hx-swap='none' class='score-controls'>
      <input type='hidden' name='room_code' value='${ROOM_CODE}' />
      <input type='hidden' name='username' value='${username}' />
      <button class='subtract' name='amount' value='-100'>-100</button>
      <button class='add' name='amount' value='100'>+100</button>
      <button class='subtract' name='amount' value='-500'>-500</button>
      <button class='add' name='amount' value='500'>+500</button>
    </form>
  </div>
"""
done << EOF
$PLAYERS
EOF


if [[ "$LOOPED" != "true" ]]; then
  echo "No players connected"
fi
