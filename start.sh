#!/usr/bin/env bash

cd "${0%/*}"
mkdir -p pubsub
mkdir -p data

tcpserver -c 1000 0 3000 ./app.sh
