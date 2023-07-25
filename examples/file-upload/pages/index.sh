
htmx_page << EOF
<h1>File Upload Example</h1>
  <form id='form' hx-encoding='multipart/form-data' hx-post='/upload'>
    <input type='file' name='file'>
    <button>Upload</button>
  </form>
EOF
