
source config.sh

htmx_page << EOF
  <h1>${PROJECT_NAME}</h1>
  <button hx-post="/bg" hx-target="#target">Do Stuff</button>
  <div id="target">Not Started</div>
  <h2>Events</h2>
  <output hx-ext="sse" sse-connect="/sse" sse-swap="update" hx-swap="beforeend">
EOF
