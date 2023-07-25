
htmx_page << EOF
<h1>File Upload Example</h1>
  <form id='form' hx-encoding='multipart/form-data' hx-post='/upload'
    _='on htmx:xhr:progress(loaded, total) set #progress.value to (loaded/total)*100'>
    <input type='file' name='file'>
    <button>Upload</button>
    <progress id='progress' value='0' max='100'></progress>
  </form>
EOF
