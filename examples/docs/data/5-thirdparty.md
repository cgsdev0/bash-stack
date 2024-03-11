---
title: Third Party Integrations
lang: en-US
...

## Upload Thing

Bash stack works with [Upload Thing](https://uploadthing.com/). Here is some example code to get you started:

```bash
# headers
header Content-Type text/html
end_headers
source config.sh
DATA="$(curl --request POST \
  --url https://uploadthing.com/api/uploadFiles \
  --header 'Content-Type: application/json' \
  --header "X-Uploadthing-Api-Key: $UPLOADTHING_SECRET" \
  --header 'X-Uploadthing-Version: 6.4.0' \
  --data '{ "files": [ { "name": "typing.gif", "size": 29634, "type": "", "customId": "" } ], 
  "acl": "public-read", "metadata": null, "contentDisposition": "inline" }')"
FILE_DATA="$(echo "$DATA" | jq -r '.data[0]')"
cat <<EO2
<script type="text/javascript">
const presigned = ${FILE_DATA};
async function handle(e) { 
  const theFile = document.querySelector("#theFile").files[0];
  const formData = new FormData();
  Object.entries(presigned.fields).forEach(([k, v]) => formData.append(k, v));
  formData.append("file", theFile);
  const res = await window.fetch(presigned.url, 
    { method: "POST", body: formData, headers: new Headers({ Accept: "application/xml", }), }); 
  window.location = presigned.fileUrl;
} 
document.addEventListener("DOMContentLoaded", (event) => { 
  document.querySelector("input[type=file]").addEventListener('change', handle); 
}); 
</script>
<input id="theFile" name="file" type="file" style="width:100vw;height:100vh;"/>
EO2
```
