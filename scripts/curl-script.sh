

IP=$(curl -4 ifconfig.co)

#Evalute the command from the curl request
eval `curl "http://192.168.0.14:8080/self-register" \
  -H 'Accept: application/json' \
  -H 'Content-Type: application/json' \
  -H "auth:  Condor-Secreto" \
  -X GET \
  -d "{
  \"ip\": \"$IP\"
}" | jq -r '.command'`