---
title: Configuration
lang: en-US
...

## General Options

You can define any environment variables you want in `config.sh`. There are a few that the framework
will check:

- `HIDE_LOGO` - if this is set, the "powered by bash" logo will be hidden
- `NO_STYLES` - if this is set, no CSS will be linked in the `<head>`
- `ENABLE_SESSIONS` - if this is 'true', bash stack will manage sessions (using a `_session` cookie).
- `TCP_PROVIDER` (default: tcpserver) - you can optionally use `nc` instead.

## Tailwind

In order to enable the tailwind support, the environment variable `TAILWIND` must be set (this will
be set by default in `config.sh` if you use the tailwind starter template)

There is also an [example tailwind-enabled project](https://github.com/cgsdev0/bash-stack/tree/main/examples/tailwind) available.
