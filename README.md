# Signing Server #

This repository has the source code for a tool to allow you to host a sub-domain in a container
that allows you to sign documents even if you do not have access to the private key for your
main ssl certificate.

It includes an sbt build that you can deploy, a docker image that you can run in any
docker environment and a Amazon AWS specific docker image that runs in ECS Fargate.


## Using service ##

The following section explains how to sign documents once the server is running.

### Sign single document ###

First compute the hash then send that to the server.

The test1234 below must match the UMPINT_SECRET set above.
```
hash=`sha256sum file | awk '{print $1}'`
curl "https://your-signing-server.com/sign?hash=${hash}&secret=test1234"
```
#### Expected response ####
If the document was signed OK you will see the below.

You can now check on umpint.com that the document is valid.
```
signed OK your-signing-server.com aee9fa810a47a5834d4ad41a5711005f048ad933bf335cc19b6e6ec5811221fe IzSAymCjkI6k+pvUxvdA2E2ILreA1S3GuEiOUzktc9e3L7aEO1gGiAR2anDIdQbQ1SDvxb6EeCpB+cM1fOOYWR1h4oMOaksvglqiqHAc8/uGAXPBDzaaOkIspQ2rvUTBP3Q3AANBwMnAg13denQcraiWN1xdrbAWo5mgLZx+w5Punan0azg4cEW0OBPpeePBSIyrFvjlCHH4OGvSzimGLjFdi+yNxXRlnMqypDNHPTemsEaBkLYRhc4Iv1kso6rCEZBTAGxVhg584whhncF3UfdcMoaoPr/N1LFzxUSutcacZDUgGaf4Aa8j6r0pf2E4KebR6TSB+dIli6gCZ0dEug==
```

### Sign many documents in a batch ###

This will sign every file in a directory from which is is run.
```
for file in `ls`;do
  sha256sum $file | awk '{print $1}' >> hashes.txt
done

curl --data-binary "@hashes.txt" "https://your-singing-server.com/sign?secret=test1234"  -H "Content-Type: plain/text"
```

## Standard Docker Build ##

This builds a Ubuntu container with a nginx reverse proxy and automatically gets ssl certificates
from letsencrypt.org

All you need to do is to point your domain name at the IP address that this container will be using.
You can even update the DNS after starting the container as it will wait till the DNS entry
matches its own IP address.

Note - this is not the recommended way to get certificates. As every time you restart the container
it requests a new certificate. See the AWS image for a better but more complex approach.

```
docker build -t signing-server:latest https://github.com/umpint/signing-server.git
docker run -p 80:80 -p 443:443 \
    -e DOCKER_HOSTNAME=sign.youwebsite.com \
    -e DOCKER_EMAIL=you@youwebsite.com  \
    -e DOCKER_SERVERHOST="https://umpint.com" \
    -e DOCKER_SECRET=asecretstring \
#    -e DOCKER_TEST=y \
    signing-server:latest
```
* DOCKER_HOSTNAME - this domain name must resolve to the IP address of the container
* DOCKER_EMAIL - an email address that will get information on the certificate renewals from
letsencrypt.com
* DOCKER_SERVERHOST - leave this unchanged
* DOCKER_SECRET - the secret that you send the server with the hash to prove it is you
* DOCKER_TEST - when this is Y only a fake SSL certificate is generated. This is recommended
when testing as you can only get 5 real certificates per week from letsencrpt.

Note - when DOCKER_TEST is set to Y you will not actually be able to sign anything as umpint.com
will not accept the certificate.

Now refer to the "Using service" section for how to sign documents.

## AWS Docker Build ##

To build run:
```
 docker build -t signing-server:latest https://github.com/umpint/signing-server.git -f Dockerfile_aws
```
To deploy

## Standard Build ##

Dependancies are:
* AdoptOpenJDK Java 11.0.7
* sbt 1.3.12

To build the standard jar package run the following.
```
git clone https://github.com/umpint/signing-server.git
cd signing-server
sbt assembly
```
You will now have:
  ```
target/scala-2.13/SigningServer-assembly-0.1.0-SNAPSHOT.jar
```

### Running standalone

To run the process it expects there to be a reverse proxy (e.g. nginx) on the host and that 
the host has the SSL certificate, and proxys on to this application on port 9000.

Before running you need to set the following environment variable:
* UMPINT_KEY - full path to your SSL private key in pem format.
* UMPINT_SECRET - this is the secret that your host sending the hashes needs to know.
* UMPINT_URL - this is the URL of you SSL certificate.
* UMPINT_SERVERHOST - this should be https://umpint.com
* UMPINT_PORT - normally 9000 - or whatever your proxy is passing on traffic to.

To run the service just run:
```
java -Dorg.scalatra.environment=production   -jar SigningServer-assembly-0.1.0-SNAPSHOT.jar
```
