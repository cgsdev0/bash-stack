
INDEX="0-index"
STRIPPED=${REQUEST_PATH#\/}
STRIPPED=${STRIPPED:-$INDEX}
MARKDOWN_FILE="data/$STRIPPED.md"

if [[ ! -f "$MARKDOWN_FILE" ]]; then
  return $(status_code 404)
fi

TOC=""
if [[ "$STRIPPED" != "$INDEX" ]]; then
  TOC="--toc"
else
  GLOBAL_TOC="<ul>"
  for FILE in data/*.md; do
    FNAME="$(basename $FILE)"
    FNAME="${FNAME%.md}"
    GENERATED="$(pandoc --from markdown --to html --standalone --wrap=preserve --highlight-style=breezeDark $FILE --toc)"
    GLOBAL_TOC+="<li>"
    GLOBAL_TOC+="<a href='#'>$(echo "$GENERATED" | xmllint --html --xpath '//*[@id="title-block-header"]/h1/text()' - 2> /dev/null)</a>"
    GLOBAL_TOC+="$(echo "$GENERATED" | xmllint --html --xpath '//*[@id="TOC"]/ul' - 2> /dev/null | sed 's@href="@href="/'$FNAME'@g')"
    GLOBAL_TOC+="</li>"
  done
  GLOBAL_TOC+="</ul>"
  GLOBAL_TOC="$(echo "$GLOBAL_TOC" | tr -d '\n')"
fi
htmx_page << EOF
  $(pandoc --from markdown --to html --standalone --wrap=preserve --highlight-style=breezeDark $MARKDOWN_FILE $TOC \
  | sed "s@</header>@</header>$GLOBAL_TOC@")
EOF
