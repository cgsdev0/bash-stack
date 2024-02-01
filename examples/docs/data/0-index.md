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

Bash stack is an **HTTP server and framework** for building modern web applications (in bash).

Bash stack uses **file-based routing**. All of the application routes should exist as
`.sh` files in the `pages/` folder of the project.

Whenever an HTTP request is made, the framework will locate the corresponding script
and execute it. Anything written to `stdout` by the script will be written to the HTTP response body.

Bash stack also pairs well with [htmx](https://htmx.org/), which is included by default.
We strongly recommend familizarizing yourself with [their examples](https://htmx.org/examples/) before proceeding.

## Showcase

These are some projects built using bash stack:

- [Connect 4](https://connect4.bashsta.cc/)
- [Wrizzle (multiplayer wordle)](https://wrizzle.bashsta.cc/)
- [Jeopardy buzzer](https://jeopardy.bashsta.cc/)
- [Github Issue Roulette](https://github2.com/)
- [Twitch 'First' Redeem](https://first.bashsta.cc/)
- [Meme Maker Pro 2003 - Enterprise Edition](https://mememakerpro2003-enterpriseedition.bashsta.cc/)
- [Redemption Arc](https://arc.bashsta.cc/)

Shipped something using bash stack? [Send us a PR](https://github.com/cgsdev0/bash-stack/blob/main/examples/docs/data/0-index.md) to add your project to the list!
