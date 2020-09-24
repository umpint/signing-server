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

