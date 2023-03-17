
PASSWORD="${COOKIES["password"]}"

if [[ "$REQUEST_METHOD" != "POST" ]]; then
  return
fi

ROOM_CODE="${FORM_DATA["room_code"]}"
ROOM_PASSWORD=$(cat "data/password-$(basename ${ROOM_CODE})")

if [[ "$ROOM_PASSWORD" != "$PASSWORD" ]]; then
  echo "Bad auth!"
  return
fi

PUBSUB_KEY="room-${ROOM_CODE}"


BUZZ_LOCK="data/buzzed-$(basename ${ROOM_CODE})"

if [[ ! -f "$BUZZ_LOCK" ]]; then
  echo "Unlocked!"
  return
fi

rm -f "$BUZZ_LOCK"

printf "event: unlock\ndata: %s\n\n" "Buzz" \
  | publish "$PUBSUB_KEY" &

echo "Unlocked!"
