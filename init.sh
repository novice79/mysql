#!/bin/bash

log () {
    printf "[%(%Y-%m-%d %T)T] %s\n" -1 "$*"
}


chown -R mysql:mysql /var/lib/mysql

sql_init_file='/tmp/mysql-init.sql'
s_id=1
if [ "$#" -ne 1 ]; then
    log "start as master db, and take into account env parameters"
    # get environment variables:
    log "MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD:=freego}"
    log "MYSQL_USER=${MYSQL_USER:=david}"
    log "MYSQL_PASSWORD=${MYSQL_PASSWORD:=freego}"
    log "MYSQL_DATABASE=${MYSQL_DATABASE:=lemp}"
    cat <<EOT > $sql_init_file
CREATE USER IF NOT EXISTS 'root'@'%' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}' ;
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
GRANT ALL ON *.* TO 'root'@'%' WITH GRANT OPTION;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED WITH mysql_native_password BY '${MYSQL_PASSWORD}';
GRANT ALL ON *.* TO '$MYSQL_USER'@'%';
CREATE USER IF NOT EXISTS 'slaveuser'@'%' IDENTIFIED WITH sha256_password BY 'freego';
GRANT REPLICATION SLAVE ON *.* TO 'slaveuser'@'%';
CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
FLUSH PRIVILEGES;
EOT
else
    log "start as slave db, ignore all env parameters"
    cat <<EOT > $sql_init_file
CHANGE MASTER TO
MASTER_HOST='$1',
MASTER_PORT=3306,
MASTER_USER='slaveuser',
MASTER_PASSWORD='freego',
MASTER_AUTO_POSITION=1;
START SLAVE;
EOT
    EX_PARA="--master-info-repository=TABLE --relay-log=$(hostname)-relay-bin"
    s_id=$((2 + RANDOM))
    # replicate from fresh slate?
    rm -rf /var/lib/mysql/*
fi

if [ ! -d /var/lib/mysql/mysql ]; then
    rm -rf /var/lib/mysql/*
    mysqld --initialize --user=mysql --datadir=/var/lib/mysql
fi

mysqld --init-file="${sql_init_file}" --user=root --server-id=${s_id} --log-bin=mysql-bin --gtid-mode=ON --enforce-gtid-consistency=true --log-slave-updates ${EX_PARA}
