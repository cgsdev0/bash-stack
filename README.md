<p align="center"><img src="https://user-images.githubusercontent.com/4583705/223574260-c94bafb3-82af-4adf-8d71-d8ef7724d287.png" alt="BASH Stack Logo" /></p>

<h2><p align="center"><a href="https://www.twitch.tv/badcop_"><img src="https://user-images.githubusercontent.com/4583705/225815615-c9c6c034-c746-4c0b-bab1-d39d65aa1275.png" /> Built live on Twitch</a></p></h2>

# Quick Start

Create a new bash stack app:
```
curl -SsL create.bashsta.cc | bash
```

# What?

- it's sort of like [next.js](https://nextjs.org/), except bash (maybe we should call it prev.sh?)

# How?

well, there are a few dependencies:
- bash 4.0+
- [tcpserver](http://cr.yp.to/ucspi-tcp/tcpserver.html) (from ucspi-tcp package)
- coreutils (tested mostly with gnu so far)

check out the examples folder for.. examples

# ...Why?

not sure

# Roadmap

- [x] file-based routing
- [x] SSE with pubsub
- [x] form data parsing
- [x] cookie parsing
- [x] url search param parsing
- [x] multipart file uploads
- [x] example apps
- [x] docs
- [ ] good docs
- [ ] database abstraction
- [x] tailwind
- [x] live reloading
- [x] URL variable parsing
- [x] higher level SSE abstraction
- [x] bootstrap script

## Disclaimer

This project is intended for educational / entertainment purposes only. In its current implementation, it is riddled with security issues, and it would probably be extremely irresponsible to use this for any sort of production grade web service.

...having said that, if you happen to use it for anything, I'd love to hear about it!
