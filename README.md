MySQL 8.0 master/slave container

Usage:
// start mysql master(on: 192.168.1.113 )
docker run -d -p 3306:3306 -p 33060:33060 --name um \
-v /data/temp/mysql:/var/lib/mysql  \
novice/mysql

// start mysql slave( repl from 192.168.1.113)
docker run -d --name um_slave \
-v /data/temp/mysql_bak:/var/lib/mysql  \
novice/mysql 192.168.1.113

P.S. default root pass=freego, with default admin user david and pass=freego
//or start master with custom user/database like
docker run -d -p 3306:3306 -p 33060:33060 --name um \
-v /data/temp/mysql:/var/lib/mysql  \
-e MYSQL_ROOT_PASSWORD=myrootpw \
-e MYSQL_USER=novice -e MYSQL_PASSWORD=mypassword -e MYSQL_DATABASE=mydb \
novice/mysql