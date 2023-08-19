
mkdir -p cache

INDEX="0-index"
STRIPPED=${REQUEST_PATH#\/}
STRIPPED=${STRIPPED:-$INDEX}
MARKDOWN_FILE="data/$STRIPPED.md"

if [[ ! -f "$MARKDOWN_FILE" ]]; then
  return $(status_code 404)
fi

  if [[ ! -f cache/global_toc ]] || [[ ! -z "$NO_CACHE" ]]; then
    GLOBAL_TOC="<div id='sidebar'><ul>"
    for FILE in data/*.md; do
      FNAME="$(basename $FILE)"
      FNAME="${FNAME%.md}"
      GENERATED="$(pandoc --from markdown --to html --standalone --wrap=preserve --highlight-style=breezeDark $FILE --toc)"
      GLOBAL_TOC+="<li>"
      GLOBAL_TOC+="<a href='/$FNAME'>$(echo "$GENERATED" | xmllint --html --xpath '//*[@id="title-block-header"]/h1/text()' - 2> /dev/null)</a>"
      GLOBAL_TOC+="$(echo "$GENERATED" | xmllint --html --xpath '//*[@id="TOC"]/ul' - 2> /dev/null | sed 's@href="@href="/'$FNAME'@g')"
      GLOBAL_TOC+="</li>"
    done
    GLOBAL_TOC+="</ul></div>"
    GLOBAL_TOC="$(echo "$GLOBAL_TOC" | tr -d '\n')"

    # save to cache
    if [[ -z "$NO_CACHE" ]]; then
      debug "cache miss :("
      echo "$GLOBAL_TOC" > cache/global_toc
    fi
  else
    debug "cache hit"
    GLOBAL_TOC="$(cat cache/global_toc)"
  fi

htmx_page << EOF
  $(pandoc --from markdown --to html --standalone --wrap=preserve --highlight-style=breezeDark $MARKDOWN_FILE \
  | sed "s@</header>@</header>$GLOBAL_TOC@")
EOF
