
# helper function to map each
# line of input to an SSE event
event_stream() {
  local line
  while IFS= read -r line; do
    event "$1" "$line"
  done
}

# start a long running task in the background,
# and pipe its output to the SSE topic 'stuff'
#
# important things to note:
# 1. we close stdin at the start with '</dev/null'
# 2. we close stdout and stderr at the end of the pipe

</dev/null ./task.sh \
  | event_stream update \
  | publish stuff &>/dev/null &

# this happens immediately; we don't need to wait
# for the above task to finish to get this response.
echo 'Job started!'
