# headers

ROOM_CODE="$(cat /dev/urandom | base64 | head -c 20 | sed 's/[+=\/]//g')"
PASSWORD="$(cat /dev/urandom | base64 | head -c 20 | sed 's/[+=\/]//g')"

echo "$PASSWORD" > "data/password-${ROOM_CODE}"
echo "" > "data/scores-${ROOM_CODE}"

printf "%s\r\n" "Set-Cookie: password=${PASSWORD}; Path=/"
printf "%s\r\n" "HX-Redirect: /host/${ROOM_CODE}"
printf "\r\n"
printf "\r\n"
