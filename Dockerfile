FROM ubuntu:18.04 as build
RUN apt-get update
RUN rm /bin/sh && ln -s /bin/bash /bin/sh
RUN apt-get -q -y install curl zip unzip
RUN curl -s https://get.sdkman.io | bash
RUN chmod a+x "$HOME/.sdkman/bin/sdkman-init.sh"
RUN source "$HOME/.sdkman/bin/sdkman-init.sh" && sdk install java 11.0.8.hs-adpt
RUN source "$HOME/.sdkman/bin/sdkman-init.sh" && sdk install sbt 1.3.13
RUN source "$HOME/.sdkman/bin/sdkman-init.sh" && sdk install scala 2.13.2

COPY . .

RUN source "$HOME/.sdkman/bin/sdkman-init.sh" && sbt assembly

FROM ubuntu:18.04
RUN apt update -y
RUN apt upgrade -y
RUN apt install unzip -y
RUN apt install vim -y
RUN apt install nginx -y
RUN apt install wget -y
RUN apt-get update -y
RUN apt-get install software-properties-common -y
RUN add-apt-repository universe -y
RUN add-apt-repository ppa:certbot/certbot -y
RUN apt-get install certbot python3-certbot-nginx -y

RUN wget https://github.com/AdoptOpenJDK/openjdk11-binaries/releases/download/jdk-11.0.8%2B10/OpenJDK11U-jdk_x64_linux_hotspot_11.0.8_10.tar.gz
RUN tar -xvf OpenJDK11U-jdk_x64_linux_hotspot_11.0.8_10.tar.gz

RUN apt install curl -y
RUN apt install dnsutils -y

COPY --from=BUILD  /target/scala-2.13/SigningServer-assembly*jar /server.jar

COPY DOCKER/static-html-directory /usr/share/nginx/html
COPY DOCKER/run_v2.sh /run.sh
RUN chmod +x run.sh
COPY DOCKER/renew_v2.sh /renew.sh
RUN chmod +x renew.sh

COPY DOCKER/nginx.conf /etc/nginx/sites-available/default
COPY DOCKER/testhome.html /testhome.html

CMD /run.sh
