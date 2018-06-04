FROM ubuntu:16.04
ENV BUILD_DATE=04_07_2018
RUN apt-get update
RUN apt-get install -y apt-transport-https
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 2930ADAE8CAF5059EE73BB4B58712A2291FA4AD5
RUN echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.6 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-3.6.list
RUN apt-get update
RUN apt-get install -y mongodb-org=3.6.5 mongodb-org-server=3.6.5 mongodb-org-shell=3.6.5 mongodb-org-mongos=3.6.5 mongodb-org-tools=3.6.5
RUN apt-get install -y pwgen
ENV TERM=xterm
VOLUME /data/db
COPY ./js /js
ADD ./mongod.conf /etc/mongod.conf
ADD ./run.sh /run.sh
ADD ./add_root_user.sh /add_root_user.sh
RUN chmod +x /run.sh && chmod +x /add_root_user.sh

CMD /run.sh