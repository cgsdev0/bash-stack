# sse

ROOM_CODE="${REQUEST_PATH##*/}"
USER_TYPE="${REQUEST_PATH%/*}"
USER_TYPE="${USER_TYPE##*/}"

PUBSUB_KEY="room-${ROOM_CODE}"

PLAYER_ID="${COOKIES["username"]}"

ROOM_DATA="data/room-$(basename ${ROOM_CODE})"


sub=$(subscribe "$PUBSUB_KEY")

output() {
  while true; do
    cat "$sub"
  done
}

output &
pid=$!

[[ "$USER_TYPE" == "player" ]] && \
  printf "event: join\ndata: %s\n\n" "${PLAYER_ID}" \
  | publish "$PUBSUB_KEY" && \
  touch "$ROOM_DATA" && \
  ((grep -qP "^${PLAYER_ID}(\tX)*$" "$ROOM_DATA" && \
  sed -i "s/^${PLAYER_ID}\tX$/${PLAYER_ID}/" "$ROOM_DATA") || \
  echo -e "$PLAYER_ID" >> "$ROOM_DATA" && \
  sort -o "$ROOM_DATA" "$ROOM_DATA")

while IFS= read -r line; do
  echo "client says $line, but i dont care" 1>&2
done

echo "CLIENT TERMINATED CONNECTION" 1>&2
kill -9 $pid&>/dev/null
wait $pid 2>/dev/null

unsubscribe "$sub"

[[ "$USER_TYPE" == "player" ]] && \
  printf "event: leave\ndata: %s\n\n" "$PLAYER_ID" |\
  publish "$PUBSUB_KEY" &&
  sed -i "s/^${PLAYER_ID}$/${PLAYER_ID}\tX/" "$ROOM_DATA"
  # sed -i "/${PLAYER_ID}/d" "$ROOM_DATA"
