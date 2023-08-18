
examples='
/route
/nested/route
/variable/route
/multiple/variables/route
/catch/all/route
/optional
/optional/
/optional/catch/all/route
/variable/and/catch/all/route
'

qp_examples='
/route?foo=bar&baz=qux
'
pages="$(cd pages; find . -type f,l)"
htmx_page << EOF
  <h1>Router Examples</h1>

  <p>These are the routes that exist:</p>
  <ul>
    $(echo "$pages" | awk '{ if ($0 != "") print "<li>"$1"</li>" }')
  </ul>
  <p>Try these links:</p>
  <ul>
    $(echo "$examples" | awk '{ if ($0 != "") print "<li><a href=\""$1"\">"$1"</a></li>" }')
  </ul>
  <p>Or these ones with query params:</p>
  <ul>
    $(echo "$qp_examples" | awk '{ if ($0 != "") print "<li><a href=\""$1"\">"$1"</a></li>" }')
  </ul>
EOF
