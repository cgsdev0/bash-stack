#!/usr/bin/env bash

cd "${0%/*}"

# remove any old subscriptions; they are no longer valid
rm -rf pubsub

mkdir -p pubsub
mkdir -p data
mkdir -p uploads

PORT=${PORT:-3000}
tcpserver -c 1000 0 $PORT ./core.sh
