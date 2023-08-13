
htmx_page << EOF
  <h1>TODO List</h1>
  <form>
    <input type="text" name="task" placeholder="New task..." />
    <button hx-put="/list" hx-target='#list' hx-swap='beforeend'>Add Task</button>
  </form>
  $(component '/list')
EOF
