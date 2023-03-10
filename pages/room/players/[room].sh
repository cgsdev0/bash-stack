
ROOM_CODE="${REQUEST_PATH##*/}"

touch "data/room-$(basename ${ROOM_CODE})"
SCORE_FILE="data/scores-$(basename ${ROOM_CODE})"
for username in $(cat "data/room-$(basename ${ROOM_CODE})"); do
  LOOPED=true
  if [[ -f "data/buzzed-$(basename ${ROOM_CODE})" ]]; then
    BUZZED=$(cat "data/buzzed-$(basename ${ROOM_CODE})")
  fi

  SCORE=$(set -o pipefail; (grep -P "$username\t" "$SCORE_FILE" | cut -f2) || echo 0);
  BUZZED_CLASS=$([[ "$BUZZED" == "$username" ]] && echo " buzzed")
  RED_CLASS=$([[ "$SCORE" -lt "0" ]] && echo " red")
  echo """
  <div class='player-wrapper'>
    <div class='player${BUZZED_CLASS}'>
      <div class='username'>${username}</div>
      <div class='score${RED_CLASS}'>${SCORE}</div>
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
done


if [[ "$LOOPED" != "true" ]]; then
  echo "No players connected"
fi
