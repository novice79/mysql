#!/usr/bin/node
const fs = require('fs');
const { spawn, spawnSync, exec, execSync } = require('child_process');
const uid = parseInt( execSync('id -u mysql').toString() );
// console.log(uid);
const randInt = (min, max)=>Math.floor(Math.random() * (max - min + 1)) + min;
let s_id = 1, extra_para='', init_sql;
const sql_init_file = '/tmp/mysql-init.sql';
// get environment variables:
const MYSQL_ROOT_PASSWORD = process.env.MYSQL_ROOT_PASSWORD || 'freego';
const MYSQL_DATABASE = process.env.MYSQL_DATABASE;
const MYSQL_USER = process.env.MYSQL_USER;
const MYSQL_PASSWORD = process.env.MYSQL_PASSWORD || 'freego';
// first two are node and script name
const paras = process.argv.slice(2)
if (paras.length == 0) {
    init_sql = 
    `
    CREATE USER IF NOT EXISTS 'root'@'%' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}' ;
    GRANT ALL ON *.* TO 'root'@'%';
    CREATE USER IF NOT EXISTS 'david'@'%' IDENTIFIED BY 'freego';
    GRANT ALL ON *.* TO 'david'@'%';
    CREATE USER IF NOT EXISTS 'slaveuser'@'%' IDENTIFIED WITH sha256_password BY 'freego';
    GRANT REPLICATION SLAVE ON *.* TO 'slaveuser'@'%';
    `;
    if(MYSQL_DATABASE){
        init_sql += `CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE} ;`;
    }
    if(MYSQL_USER){
        init_sql += `
        CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
        `;
    }
    if(MYSQL_DATABASE && MYSQL_USER){
        init_sql += `GRANT ALL ON '${MYSQL_DATABASE}'.* TO '${MYSQL_USER}'@'%';`;
    }
    init_sql += 'FLUSH PRIVILEGES ;';
    
} else {
    init_sql = 
    `
    CHANGE MASTER TO
    MASTER_HOST='${paras[0]}',
    MASTER_PORT=3306,
    MASTER_USER='slaveuser',
    MASTER_PASSWORD='freego',
    MASTER_AUTO_POSITION=1;
    START SLAVE;
    `;
    s_id = randInt(2, 2**32);
    extra_para = '--master-info-repository=TABLE';
}
fs.writeFileSync(sql_init_file, init_sql);
const mysqld = exec(`mysqld --init-file="${sql_init_file}" --server-id=${s_id} --log-bin=mysql-bin --gtid-mode=ON --enforce-gtid-consistency=true --log-slave-updates ${extra_para}`, {uid});
mysqld.stdout.on('data', data => console.log(data));
mysqld.stderr.on('data', data => console.log(data));
mysqld.on('close', (code) => {
    console.log(`mysqld exited with code ${code}`);
});