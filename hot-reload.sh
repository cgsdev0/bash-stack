#!/usr/bin/env bash

cd "${0%/*}"
mkdir -p pubsub
mkdir -p data

function finish {
  /bin/kill -9 $server_pid -$server_pid
}
trap finish EXIT

while true; do
  tcpserver -c 1000 0 3000 ./app.sh &
  server_pid=$!
  inotifywait app.sh -e MODIFY
  /bin/kill -9 $server_pid -$server_pid
  wait $server_pid
done
