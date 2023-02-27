#!/usr/bin/env bash

function finish {
  kill $server_pid
}
trap finish EXIT

while true; do 
  tcpserver 0 3000 ./app.sh &
  server_pid=$!
  inotifywait app.sh -e MODIFY
  kill $server_pid
done
