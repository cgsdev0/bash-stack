# headers

ROOM_CODE="$(cat /dev/urandom | base64 | head -c 8 | sed 's/[+=\/]//g')"

printf "%s\r\n" "Set-Cookie: password=${FORM_DATA['password']}; Path=/"
printf "%s\r\n" "HX-Redirect: /host/${ROOM_CODE}"
printf "\r\n"
