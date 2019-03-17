FROM mysql
LABEL maintainer="David <david@cninone.com>"

# Get noninteractive frontend for Debian to avoid some problems:
#    debconf: unable to initialize frontend: Dialog
ENV DEBIAN_FRONTEND noninteractive

ENV LANG       en_US.UTF-8
ENV LC_ALL	   "C.UTF-8"
ENV LANGUAGE   en_US:en

RUN apt-get update -y && apt-get install -y tzdata locales procps net-tools inetutils-ping telnet curl \
	&& rm -rf /var/lib/apt/lists/* \
	&& locale-gen en_US.UTF-8 zh_CN.UTF-8

ENV TZ=Asia/Chongqing
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone ; \
	sed '/\[mysqld\]/a default_authentication_plugin=mysql_native_password' -i /etc/mysql/conf.d/docker.cnf

COPY init.sh /
RUN rm -f /var/lib/mysql/auto.cnf
EXPOSE 3306 33060

ENTRYPOINT ["/init.sh"]
