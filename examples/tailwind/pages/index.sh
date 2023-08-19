
source config.sh

htmx_page << EOF
  <h1 class="text-blue-500 text-4xl mt-3 mb-3">${PROJECT_NAME}</h1>
  <button class="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded" hx-post="/count" hx-swap="none">Count</button>
  <button class="bg-red-500 hover:bg-red-700 text-white font-bold py-2 px-4 rounded" hx-post="/reset" hx-swap="none">Reset</button>
  $(component '/count')
EOF
