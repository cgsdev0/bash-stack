---
title: API Reference
lang: en-US
...

## Directives

The first line of each route script is checked for a "directive". These are special
comments that let you override the way a route is handled internally.

These are the directives that currently exist:

- `# sse` - this route will be used for [Server-Sent Events](https://developer.mozilla.org/en-US/docs/Web/API/Server-sent_events) [(example)](https://github.com/cgsdev0/bash-stack/blob/main/examples/jeopardy-buzzer/pages/sse/%5Busertype%5D/%5Broom%5D.sh)
- `# allow-uploads` - this route will allow file uploads via a multipart encoded form. [(example)](https://github.com/cgsdev0/bash-stack/blob/main/examples/file-upload/pages/upload.sh)
- `# headers` - this route will be responsible for writing its own headers section, in addition to the response body. [(example)](https://github.com/cgsdev0/bash-stack/blob/main/examples/jeopardy-buzzer/pages/login.sh)


## Request Variables

The following variables are available in all route handlers:

- `REQUEST_METHOD` - the HTTP verb used
- `REQUEST_PATH` - the relative path of the request
- `REQUEST_QUERY` - the raw (unparsed) query string

The framework will automatically parse the request and populate the following associative arrays:

- `HTTP_HEADERS` - The parsed request headers
- `QUERY_PARAMS` - The parsed query parameter string
- `FORM_DATA` - The parsed form data (if applicable)
- `PATH_VARS` - The parsed variable names for dynamic and catch-all routes
- `COOKIES` - The parsed cookies from the request headers

The following are only used if you are writing an upload handler:

- `FILE_UPLOADS` - A mapping of input names -> tmp files
- `FILE_UPLOAD_TYPES` - A mapping of input names -> file upload types  (according to the request)
- `FILE_UPLOAD_NAMES` - A mapping of input names -> original filenames
