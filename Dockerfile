FROM ubuntu:18.04
LABEL maintainer="David <david@cninone.com>"

# Get noninteractive frontend for Debian to avoid some problems:
#    debconf: unable to initialize frontend: Dialog
ENV DEBIAN_FRONTEND noninteractive

ENV LANG       en_US.UTF-8
ENV LC_ALL	   "C.UTF-8"
ENV LANGUAGE   en_US:en

RUN apt-get update -y && apt-get install -y \
    software-properties-common language-pack-en-base \
    curl git vim cron inetutils-ping wget net-tools tzdata sudo


RUN useradd -ms /bin/bash david && usermod -aG sudo david
RUN echo 'david:freego' | chpasswd
RUN echo 'root:freego_2019' | chpasswd

ENV TZ=Asia/Chongqing
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
# nodejs begin
RUN curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash - && sudo apt-get install -y nodejs
# nodejs end

# mysql begin
RUN wget https://dev.mysql.com/get/mysql-apt-config_0.8.11-1_all.deb && dpkg -i mysql*.deb && rm mysql*.deb
RUN { \
		echo mysql-community-server mysql-community-server/root-pass password 'freego'; \
		echo mysql-community-server mysql-community-server/re-root-pass password 'freego'; \
	} | debconf-set-selections \
	&& apt-get update && apt-get install -y \
        mysql-server lsof \
	&& rm -rf /var/lib/apt/lists/* 

# mysql end

COPY init.js /
RUN chmod +x /init.js && rm -f /var/lib/mysql/auto.cnf
VOLUME ["/var/lib/mysql"]


EXPOSE  3306 33060

ENTRYPOINT ["/init.js"]
