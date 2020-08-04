while true
do
	echo "renewal process sleeping 12 hours..."
	sleep 43200
	echo "renew certbot"
	certbot renew
	echo "renew certbot done"
done
