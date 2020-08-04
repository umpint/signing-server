#!/bin/bash

while true
do
	sleep 60
	echo "renew certbot"
	certbot renew
	echo "renew certbot done"
	echo "checking if certificate changed"
	ls -lrt  /etc/letsencrypt/live/$DOCKER_HOSTNAME/privkey.pem
	CURTIME=$(date +%s)
	FILETIME=$(stat /etc/letsencrypt/live/$DOCKER_HOSTNAME/privkey.pem -c %Y)
	TIMEDIFF=$(expr $CURTIME - $FILETIME)
	echo "$TIMEDIFF now $CURTIME certificat $FILETIME"
	if [ $TIMEDIFF -lt 300 ]; then
		echo "update secrets"
		/update-secrets.sh
	fi
	echo "renewal process sleeping 12 hours..."
	sleep 43200
done
