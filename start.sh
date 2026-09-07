#!/usr/bin/env bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
export PROJECT_ROOT="${PROJECT_ROOT-$PWD}"
export CORE_SH="${CORE_SH-$SCRIPT_DIR/core.sh}"
export CONFIG_SH="${CONFIG_SH-$PROJECT_ROOT/config.sh}"

cd "$PROJECT_ROOT"

[[ -f "$CONFIG_SH" ]] && source "$CONFIG_SH"

if [[ "${DEV:-true}" == "true" ]] && [[ ! -z "$TAILWIND" ]]; then
   npx tailwindcss@v3 -i ./static/style.css -o ./static/tailwind.css --watch=always 2>&1 \
     | sed '/^[[:space:]]*$/d;s/^/[tailwind] /' &
   PID=$!
fi

if [[ "${DEV:-true}" != "true" ]]; then
  export ROUTES_CACHE=$(mktemp)
fi

# remove any old subscriptions; they are no longer valid
rm -rf pubsub

mkdir -p sessions
mkdir -p pubsub
mkdir -p data
mkdir -p uploads

PORT=${PORT:-3000}

TCP_PROVIDER=${TCP_PROVIDER:-tcpserver}

case "$TCP_PROVIDER" in
  tcpserver)
    echo -n "Listening on port "
    tcpserver -1 -o -l 0 -H -R -c 1000 0 $PORT "$CORE_SH"
    ;;
  nc)
    [[ ! -p nc_tunnel ]] && mkfifo nc_tunnel
    [[ "${DEV:-true}" == true ]] && \
      echo "WARNING: performance while using netcat will be significantly degraded!"
    echo "Listening on port $PORT"
    while true; do
      < nc_tunnel nc -l $PORT | "$CORE_SH" >nc_tunnel
    done
    ;;
  *)
    echo "ERROR: unsupported TCP_PROVIDER"
    exit 1
    ;;
esac

if [[ ! -z "$PID" ]]; then
  kill "$PID"
fi
