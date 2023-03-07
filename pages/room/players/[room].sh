
ROOM_CODE="${REQUEST_PATH##*/}"

for username in $(cat "data/room-$(basename ${ROOM_CODE})"); do
  LOOPED=true
  if [[ -f "data/buzzed-$(basename ${ROOM_CODE})" ]]; then
    BUZZED=$(cat "data/buzzed-$(basename ${ROOM_CODE})")
  fi
  if [[ "$BUZZED" == "$username" ]]; then
  echo "<div class='player buzzed'>${username}</div>"
  else
  echo "<div class='player'>${username}</div>"
  fi
done


if [[ "$LOOPED" != "true" ]]; then
  echo "No players connected"
fi
