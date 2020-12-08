#!/bin/bash

echo "copying files to secrets!"
for file in cert.pem chain.pem fullchain.pem privkey.pem
do
        data=`cat /etc/letsencrypt/live/$DOCKER_HOSTNAME/$file`
        aws secretsmanager get-secret-value --secret-id  certificates/$DOCKER_HOSTNAME/$file >/dev/null
        if [ $? == 0 ]; then
          aws secretsmanager update-secret --secret-id certificates/$DOCKER_HOSTNAME/$file --secret-string="$data"
        else
          aws secretsmanager create-secret --name certificates/$DOCKER_HOSTNAME/$file --secret-string="$data"
        fi
done

echo "sending renewal file"
data=`cat /etc/letsencrypt/renewal/${DOCKER_HOSTNAME}.conf`
aws secretsmanager get-secret-value --secret-id  certificates/$DOCKER_HOSTNAME/renewal >/dev/null
if [ $? == 0 ]; then
   aws secretsmanager update-secret --secret-id certificates/$DOCKER_HOSTNAME/renewal --secret-string="$data"
else
   aws secretsmanager create-secret --name certificates/$DOCKER_HOSTNAME/renewal --secret-string="$data"
fi

echo "sending account data"
id=`cat /etc/letsencrypt/renewal/${DOCKER_HOSTNAME}.conf |grep account | awk '{print $3}'`
echo "id is $id"


for file in meta.json private_key.json regr.json
do
	filepath=/etc/letsencrypt/accounts/acme-v02.api.letsencrypt.org/directory/$id/$file
	echo "sending $filepath"
	data=`cat $filepath`
	aws secretsmanager get-secret-value --secret-id  certificates/$DOCKER_HOSTNAME/$file > /dev/null
	if [ $? == 0 ]; then
   		aws secretsmanager update-secret --secret-id certificates/$DOCKER_HOSTNAME/$file --secret-string="$data"
		echo "updated $?"
	else
   		aws secretsmanager create-secret --name certificates/$DOCKER_HOSTNAME/$file --secret-string="$data"
		echo "added $?"
	fi
done

