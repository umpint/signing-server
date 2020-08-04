#!/bin/bash
set -m

echo "starting run"
echo "DOCKER_EMAIL         [$DOCKER_EMAIL]"
echo "DOCKER_HOSTEDZONEID  [$DOCKER_HOSTEDZONEID]"
echo "DOCKER_HOSTNAME      [$DOCKER_HOSTNAME]"
echo "DOCKER_SECRET        [$DOCKER_SECRET]"
echo "DOCKER_SERVERHOST    [$DOCKER_SERVERHOST]"
echo "DOCKER_TEST          [$DOCKER_TEST]"



export UMPINT_KEY=/etc/letsencrypt/live/$DOCKER_HOSTNAME/privkey.pem
export UMPINT_SECRET=$DOCKER_SECRET
export UMPINT_URL=$DOCKER_HOSTNAME
export UMPINT_SERVERHOST=$DOCKER_SERVERHOST
export UMPINT_HOMEPAGE=/testhome.html
export UMPINT_PORT=9000
if [ "_$DOCKER_TEST" = "_y" ]; then
	CERTBOT_TEST="--test-cert"
fi


echo "getting secret"
#by grepping we are sure key valid. To get new key just remove contents.
# DO NOT delete secret in AWS as can not re-add for 30 days.
aws secretsmanager get-secret-value --secret-id  certificates/$DOCKER_HOSTNAME/privkey.pem | grep "BEGIN PRIVATE KEY" >/dev/null
if [ $? == 0 ]; then
        #we have a values so get the data
        for file in cert.pem chain.pem fullchain.pem privkey.pem
        do
                mkdir -p /etc/letsencrypt/live/$DOCKER_HOSTNAME
                aws secretsmanager get-secret-value --secret-id  certificates/$DOCKER_HOSTNAME/$file| jq ".SecretString" | sed -e s/\"//g | sed -e 's/\\n/\
/g' > /etc/letsencrypt/live/$DOCKER_HOSTNAME/$file
                echo "got $file"
        done
        chmod 400 /etc/letsencrypt/live/$DOCKER_HOSTNAME/*
        ls -l  /etc/letsencrypt/live/$DOCKER_HOSTNAME
        echo "keys copied"
        cp /nginx.have_cert.conf /etc/nginx/sites-available/default
        echo "copied updated nginx config"
fi

echo "sedding /etc/nginx/sites-available/default with $DOCKER_HOSTNAME"
sed -i -e s/@@HOSTNAME@@/$DOCKER_HOSTNAME/ /etc/nginx/sites-available/default
echo "starting nginx"
nginx
echo "sleeping 10 for startup..."
sleep 10
myip=`curl https://api.ipify.org/`
hostip=`dig +short $DOCKER_HOSTNAME | head | awk '{print $1}'`
echo "my ip from api.ipify.org: $myip ip of hostname: $hostip"

if [  "_$myip" != "_$hostip" ]; then
        echo "ips do not match so updating DNS"
        sed -i -e s/@@DOCKER_HOSTNAME@@/$DOCKER_HOSTNAME/ /update-dns.json
        sed -i -e s/@@IPADDRESS@@/$myip/ /update-dns.json
        cat /update-dns.json
        aws route53 change-resource-record-sets --hosted-zone-id $DOCKER_HOSTEDZONEID --change-batch file:///update-dns.json
fi

while [ "_$myip" != "_$hostip" ]
do
	echo "looping $myip ne $hostip"
	sleep 10
	myip=`curl https://api.ipify.org/`
	hostip=`dig +short $DOCKER_HOSTNAME | head | awk '{print $1}'`
done

echo "equal $myip and $hostip"

if [ ! -e /etc/letsencrypt/live/$DOCKER_HOSTNAME/privkey.pem ]; then
        echo "getting certificate"
        certbot --nginx $CERTBOT_TEST -n  -d $DOCKER_HOSTNAME --agree-tos --email $DOCKER_EMAIL
        ls -lrt /etc/letsencrypt/live/$DOCKER_HOSTNAME/
else
        echo "renew certbot as have a key..."
        certbot renew
        ls -lrt /etc/letsencrypt/live/$DOCKER_HOSTNAME/
fi


echo "copying key to secrets manager incase updated"
/update-secrets.sh


if [ ! -f /etc/letsencrypt/live/$DOCKER_HOSTNAME/privkey.pem ]
then
        echo "no pem found - sleeping to debug"
        sleep 3600
fi


echo "starting renewal process in background.."
/renew.sh &
echo "running on pid $!"

echo "starting java server"
/jdk-11.0.8+10/bin/java -Dorg.scalatra.environment=production   -jar /server.jar
