# sse

ROOM_CODE="${PATH_VARS[room]}"
USER_TYPE="${PATH_VARS[usertype]}"

PUBSUB_KEY="room-${ROOM_CODE}"

# required - this is the pubsub topic
topic() {
  echo "$PUBSUB_KEY"
}

# optional - this is a hook for when the connection opens
on_open() {
  PLAYER_ID="${COOKIES["username"]}"
  ROOM_DATA="data/room-$(basename ${ROOM_CODE})"

  if [[ "$USER_TYPE" == "player" ]]; then
    event join "$PLAYER_ID" | publish "$PUBSUB_KEY"

    touch "$ROOM_DATA"

    if grep -qP "^${PLAYER_ID}(\tX)*$" "$ROOM_DATA"; then
      sed -i "s/^${PLAYER_ID}\tX$/${PLAYER_ID}/" "$ROOM_DATA"
    else
      echo -e "$PLAYER_ID" >> "$ROOM_DATA"
      sort -o "$ROOM_DATA" "$ROOM_DATA"
    fi
  fi
}

# optional - this is a hook for when the connection closes
on_close() {
  if [[ "$USER_TYPE" == "player" ]]; then
    event leave "$PLAYER_ID" | publish "$PUBSUB_KEY"
    sed -i "s/^${PLAYER_ID}$/${PLAYER_ID}\tX/" "$ROOM_DATA"
  fi
}
