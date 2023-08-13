
touch data/list
DATA=$(cat data/list)

listify() {
  awk '{ print "<li><button hx-delete=\"/list\" hx-swap=\"delete\" hx-target=\"closest li\" hx-vals='\''{\"item\": \""$1"\"}'\''>X</button>"; $1 = ""; print $0"</li>" }'
}

if [[ "$REQUEST_METHOD" == "DELETE" ]]; then
  # note: this is definitely susceptible to evil inputs
  sed -i "/^${FORM_DATA[item]} /d" data/list
  return $(status_code 200)
fi

if [[ "$REQUEST_METHOD" == "PUT" ]]; then
  ITEM="$(uuidgen) ${FORM_DATA[task]}"
  echo "$ITEM" >> data/list
  echo "$ITEM" | listify
  return $(status_code 200)
fi

htmx_page << EOF
<ul id="list">
  $([[ "$DATA" == "\n" || "$DATA" == "" ]] || echo "$DATA" | listify)
</ul>
EOF
