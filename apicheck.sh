#!/bin/sh

# Authentication variables
email='""'
password='""'
apiEndpoint="http://api.ownzones.com/"

echo "" > response
echo "" > token
# LogIn and get access token
#curl -X POST -H "Content-type: application/json" \
#-d "type:credentials,email:adam.arredondo@ownzones.com,password:f9XRzSPfMGLb" --dump-header token http://api.ownzones.com/login

curl -# -H "Content-Type: application/json" \
-X POST -d '{"type":"credentials","email":'"$email"',"password":'"$password"'}' --dump-header response $apiEndpoint"login" > token

# Check HTTP Status code and returns if 200

httpStatus="$(awk '/HTTP/ {print $2;}' response)"
# echo $httpStatus

if [ "$httpStatus" = "200" ]
then
# Reads and parses the token file to capture just the accessToken needed to make API calls
accessToken="$(cat token | jq '.refreshToken' | sed s/'"'// | sed s/'"'// )"
curl -# -H "Accept-Language: application/json" \
-H "Content-Type: application/json" \
-H "X-Instance: instance" \
-H "Authorization: $accessToken" \
$apiEndpoint \
--dump-header channelsResponseHeaders
channelStatus="$(awk '/HTTP/ {print $2;}' channelsResponseHeaders)"
  if [ "$channelStatus" = "200" ]
  then
      echo "channel API OK"
  else
      echo "channel API DEAD"
  fi
else
    echo "Authentication Failed"
fi
