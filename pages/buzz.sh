
PLAYER_ID="${COOKIES["username"]}"

if [[ "$REQUEST_METHOD" != "POST" ]]; then
  return
fi

ROOM_CODE="${FORM_DATA["room_code"]}"

PUBSUB_KEY="room-${ROOM_CODE}"


BUZZ_LOCK="data/buzzed-$(basename ${ROOM_CODE})"

if [[ -f "$BUZZ_LOCK" ]]; then
  echo "Too slow :("
  return
fi

echo "$PLAYER_ID" > "$BUZZ_LOCK"


printf "event: buzz\ndata: %s\n\n" "Reset" \
  | publish "$PUBSUB_KEY"

echo "Buzzed!"
