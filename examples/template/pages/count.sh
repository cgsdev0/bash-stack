
if [[ ! -f data/count ]]; then
  echo "0" > data/count
fi

COUNT=$(cat data/count)

if [[ "$REQUEST_METHOD" == "POST" ]]; then
  # increment the count
  COUNT=$(( COUNT + 1 ))
  echo "$COUNT" > data/count
fi

htmx_page << EOF
  <p id="count" hx-swap-oob="true">$COUNT</p>
EOF
