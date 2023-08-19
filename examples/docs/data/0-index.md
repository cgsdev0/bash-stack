---
title: Bash Stack Documentation
lang: en-US
...

## Quick Start

create a new bash stack app:
```
curl -SsL create.bashsta.cc | bash
```

## Dependencies

there are a few dependencies:

- bash 4.0+
- [tcpserver](http://cr.yp.to/ucspi-tcp/tcpserver.html) (from ucspi-tcp package)
- gnu coreutils

optionally...

- nodejs (for [tailwind](https://tailwindcss.com/) support)
- docker (for deployment)

## Overview

Bash Stack uses **file-based routing**. All of the application routes should exist as
`.sh` files in the `pages/` folder of the project.

Whenever an HTTP request is made, the framework will locate the corresponding script
and execute it. Anything written to `stdout` by the script will be written to the HTTP response body.

Bash Stack also pairs well with [htmx](https://htmx.org/), which is included by default.
We strongly recommend familizarizing yourself with [their examples](https://htmx.org/examples/) before proceeding.
