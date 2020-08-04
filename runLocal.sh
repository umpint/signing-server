
export aws_region=`cat ~/.aws/config | grep "^region" | awk '{print $3}'`
export aws_keyid=`cat ~/.aws/credentials | grep "^aws_access_key_id" | awk '{print $3}'`
export aws_key=`cat ~/.aws/credentials | grep "^aws_secret_access_key" | awk '{print $3}'`

docker build -t signing-server .

docker run -p 8081:80 -p 443:443 -e DOCKER_HOSTNAME=sign.dummybank.umpint.com -e DOCKER_EMAIL=robin.owens@umpint.com  -e DOCKER_SERVERHOST="https://umpint.com" -e DOCKER_SECRET=12392fds2fdsa9393jcf9cj43 \
-e AWS_ACCESS_KEY_ID=$aws_keyid -e AWS_SECRET_ACCESS_KEY=$aws_key \
-e AWS_DEFAULT_REGION=$aws_region -e DOCKER_HOSTEDZONEID="/hostedzone/alphanumberic" \
-e DOCKER_TEST=y \
signing-server:latest



#  -e DOCKER_TEST=y to use test certificate
