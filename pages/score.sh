
USERNAME="${FORM_DATA["username"]}"
ROOM_CODE="${FORM_DATA["room_code"]}"
AMOUNT="${FORM_DATA["amount"]}"
PASSWORD="${COOKIES["password"]}"

ROOM_PASSWORD=$(cat "data/password-$(basename ${ROOM_CODE})")

if [[ "$ROOM_PASSWORD" != "$PASSWORD" ]]; then
  echo "Bad auth!"
  return
fi

SCORE_FILE="data/scores-$(basename ${ROOM_CODE})"

if result=$(grep -P "$USERNAME\t" "$SCORE_FILE"); then
  SCORE=$(echo "$result" | cut -f2)
  NEW_SCORE=$(( SCORE + AMOUNT ))
  sed -i "s/$USERNAME\t$SCORE/$USERNAME\t$NEW_SCORE/" "$SCORE_FILE"
else
  printf "%s\t%s\n" "$USERNAME" "$AMOUNT" >> "$SCORE_FILE"
fi

RED_CLASS=$([[ "$NEW_SCORE" -lt "0" ]] && echo " red")
echo "<div class='score${RED_CLASS}' id='score-for-${USERNAME}' hx-swap-oob='true'>$NEW_SCORE</div>"

PUBSUB_KEY="room-${ROOM_CODE}"
printf "event: score\ndata: %s\n\n" "idk" \
  | publish "$PUBSUB_KEY"
