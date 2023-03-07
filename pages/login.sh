# headers

PLAYER_ID=$(echo "${FORM_DATA["username"]}" | sed 's/[^a-zA-Z_0-9]//g' | head -c 20)
printf "%s\r\n" "Set-Cookie: username=${PLAYER_ID}; Path=/"
printf "%s\r\n" "HX-Refresh: true"
printf "\r\n"
