echo "starting run"
export UMPINT_KEY=/etc/letsencrypt/live/$DOCKER_HOSTNAME/privkey.pem
export UMPINT_SECRET=$DOCKER_SECRET
export UMPINT_URL=$DOCKER_HOSTNAME
export UMPINT_SERVERHOST=$DOCKER_SERVERHOST
export UMPINT_HOMEPAGE=/testhome.html
export UMPINT_PORT=9000
if [ "_$DOCKER_TEST" = "_y" ]; then
	CERTBOT_TEST="--test-cert"
fi

sed -i -e s/@@HOSTNAME@@/$DOCKER_HOSTNAME/ /etc/nginx/sites-available/default
echo "starting nginx"
nginx
echo "sleeping 10 for startup..."
sleep 10
myip=`curl https://api.ipify.org/`
hostip=`dig +short $DOCKER_HOSTNAME | head | awk '{print $1}'`
echo $myip ne $hostip

while [ "_$myip" != "_$hostip" ]
do
	echo "looping $myip ne $hostip"
	sleep 10
	myip=`curl https://api.ipify.org/`
	hostip=`dig +short $DOCKER_HOSTNAME | head | awk '{print $1}'`
done

echo "equal $myip and $hostip"

echo "getting certificate"
certbot --nginx $CERTBOT_TEST -n  -d $DOCKER_HOSTNAME --agree-tos --email $DOCKER_EMAIL
echo "have certificates"

echo "starting renewal process in background.."
renew.sh &
echo "running on pid $!"

echo "starting java server"
/jdk-11.0.8+10/bin/java -Dorg.scalatra.environment=production   -jar /server.jar
