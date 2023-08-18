
htmx_page <<EOF
<h1>Route Info</h1>
<pre>
REQUEST_PATH=${REQUEST_PATH}

ROUTE_SCRIPT=${ROUTE_SCRIPT}

PATH_VARS:
$(for i in "${!PATH_VARS[@]}";do printf "%s=%s\n" "$i" "${PATH_VARS[$i]}";done)

QUERY_PARAMS:
$(for i in "${!QUERY_PARAMS[@]}";do printf "%s=%s\n" "$i" "${QUERY_PARAMS[$i]}";done)
</pre>
EOF
