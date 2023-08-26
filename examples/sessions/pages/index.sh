
source config.sh

htmx_page << EOF
  <h1>${PROJECT_NAME}</h1>
  <p>Your session ID: ${SESSION_ID:-not yet set}</p>
  <p>Your session value: ${SESSION[test]:-not yet set}</p>
  <button hx-post="/true" hx-swap="none">True</button>
  <button hx-post="/false" hx-swap="none">False</button>
EOF
