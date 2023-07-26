
source config.sh

htmx_page << EOF
  <h1>${PROJECT_NAME}</h1>
  <button hx-post="/count" hx-swap="none">Count</button>
  <button hx-post="/reset" hx-swap="none">Reset</button>
  $(component '/count')
EOF
