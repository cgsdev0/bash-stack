# headers

ROOM_CODE="$(cat /dev/urandom | base64 | head -c 20 | sed 's/[+=\/]//g')"
PASSWORD="$(cat /dev/urandom | base64 | head -c 20 | sed 's/[+=\/]//g')"

echo "$PASSWORD" > "data/password-${ROOM_CODE}"
COOKIE_STR=$(urlencode "password=${PASSWORD}; Path=/")
printf "%s\r\n" "Set-Cookie: ${COOKIE_STR}"
printf "%s\r\n" "HX-Redirect: /host/${ROOM_CODE}"
printf "\r\n"
