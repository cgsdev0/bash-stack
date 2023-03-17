
PASSWORD="${COOKIES["password"]}"

if [[ "$REQUEST_METHOD" != "POST" ]]; then
  return
fi

PLAYER_ID="${REQUEST_PATH##*/}"

ROOM_CODE="${FORM_DATA["room_code"]}"
ROOM_PASSWORD=$(cat "data/password-$(basename ${ROOM_CODE})")
ROOM_DATA="data/room-$(basename ${ROOM_CODE})"
SCORE_DATA="data/scores-$(basename ${ROOM_CODE})"

if [[ "$ROOM_PASSWORD" != "$PASSWORD" ]]; then
  echo "Bad auth!"
  return
fi

PUBSUB_KEY="room-${ROOM_CODE}"

sed -i "/^${PLAYER_ID}\tX$/d" "$ROOM_DATA"
sed -i "/^${PLAYER_ID}\t[0-9]*$/d" "$SCORE_DATA"


printf "event: kick\ndata: %s\n\n" "Buzz" \
  | publish "$PUBSUB_KEY" &

echo "$PLAYER_ID"
