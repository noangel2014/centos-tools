#!/bin/bash
#mysqldump
#by nmfox.com 2019

echo -e "33[32m--------------------------------33[1m"
echo "system is starting,please wait...."
sleep 2

if [ $UID -ne 0 ];then
echo "must to be use root user"
exit 0
fi

MYSQL_USR=user
MYSQL_PW=password
MYSQL_DB=dbname
MYSQL_DIR=/root/
MYSQL_CMD=/usr/bin/mysqldump
FENSIZE=10m

TOTIM=$(date +%Y%m%d)
DIRBAK_NAME=$MYSQL_DIR$TOTIM
SQLBAK_NAME=$MYSQL_DB$TOTIM.sql
ZIPBAK_NAME=$MYSQL_DB$TOTIM.zip
FENBAK_NAME=back$TOTIM

mkdir $DIRBAK_NAME
$MYSQL_CMD -u$MYSQL_USR -p$MYSQL_PW $MYSQL_DB > $DIRBAK_NAME/$SQLBAK_NAME
if [ $? -eq 0 ];then
echo "mysqldump is successfully"
fi

cd $DIRBAK_NAME
zip $ZIPBAK_NAME $SQLBAK_NAME
if [ $? -eq 0 ];then
echo "mysqzip is successfully"
fi

zip -s $FENSIZE $ZIPBAK_NAME --out $FENBAK_NAME
if [ $? -eq 0 ];then
echo -e "33[37m--------------------------------33[1m"
echo "mysqlback is successfully"
fi