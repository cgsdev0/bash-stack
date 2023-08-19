---
title: Routing
lang: en-US
...

## Matching

Routes are matched with the following priority (highest at the top):

- Simple routes
- Dynamic routes
- Catch-all routes

For a more thorough example, please check out the [example router project](https://github.com/cgsdev0/bash-stack/tree/main/examples/router).

## Simple Routes

Simple routes are routes with no variables. For example:

```
    pages
    ├── index.sh
    └── list.sh
```

Both of these are simple routes, matching requests to `/` and `/list`.

## Dynamic Routes

Dynamic routes have one or more variables, represented by files with square brackets.

```
    pages
    ├── multiple
    │   └── [variables]
    │       └── [route].sh
```

As an example, both requests to `/multiple/a/b` and `/multiple/1/2` would match this route.

## Catch-All Routes

Catch-all routes have match one or more route segments.

```
    pages
    ├── catchall
    │   └── [...example].sh
```

As an example, both requests to `/catchall/a` and `/catchall/a/b` would match this route.

You can also make a catch-all segment **optional** to match 0 or more segments, like so:

```
    pages
    ├── catchall
    │   └── [[...example]].sh
```

This route would match all of the following request paths:

- `/catchall`
- `/catchall/`
- `/catchall/a`
- `/catchall/a/b/c`

## Static Files

By default, bash stack will server files in the `static/` folder. These files are available by making
`GET` requests to `/static/{filename}`.
