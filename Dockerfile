FROM ubuntu:14.04
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927
RUN echo "deb http://repo.mongodb.org/apt/ubuntu trusty/mongodb-org/3.2 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-3.2.list
RUN apt-get update
RUN apt-get install -y mongodb-org=3.2.7 mongodb-org-server=3.2.7 mongodb-org-shell=3.2.7 mongodb-org-mongos=3.2.7 mongodb-org-tools=3.2.7
RUN apt-get install -y pwgen
ENV TERM=xterm
VOLUME /data/db
COPY ./js /js
ADD ./mongod.conf /etc/mongod.conf
ADD ./run.sh /run.sh
ADD ./add_root_user.sh /add_root_user.sh
RUN chmod +x /run.sh && chmod +x /add_root_user.sh

CMD /run.sh