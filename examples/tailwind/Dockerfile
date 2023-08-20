FROM node:20-alpine3.17 as tailwind

COPY . /app

WORKDIR /app

RUN npx tailwindcss -i /app/static/style.css -o /app/build.css --minify

FROM ubuntu as prod

ENV DEV=false

RUN apt-get update && apt-get install ucspi-tcp

EXPOSE 3000

COPY . /app

COPY --from=tailwind /app/build.css /app/static/tailwind.css

CMD [ "/app/start.sh" ]
