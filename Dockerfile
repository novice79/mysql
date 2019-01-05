FROM mysql
LABEL maintainer="David <david@cninone.com>"

# Get noninteractive frontend for Debian to avoid some problems:
#    debconf: unable to initialize frontend: Dialog
ENV DEBIAN_FRONTEND noninteractive

ENV LANG       en_US.UTF-8
ENV LC_ALL	   "C.UTF-8"
ENV LANGUAGE   en_US:en

RUN apt-get update -y && apt-get install -y tzdata \
	&& rm -rf /var/lib/apt/lists/*

ENV TZ=Asia/Chongqing
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

COPY init /
RUN rm -f /var/lib/mysql/auto.cnf
EXPOSE 3306 33060

ENTRYPOINT ["/init"]
