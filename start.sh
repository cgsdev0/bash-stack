#!/usr/bin/env bash

cd "${0%/*}"
mkdir -p pubsub
mkdir -p data
mkdir -p uploads

PORT=${PORT:-3000}
tcpserver -c 1000 0 $PORT ./core.sh
