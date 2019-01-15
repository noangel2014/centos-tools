#!/bin/bash
#在使用之前，请提前创建以下各个目录
#tar -g tarinfo增量备份方法 增量备份
#获取当前时间
date_now=$(date "+%Y%m%d-%H%M%S")
backUpFolder=/home/backup/
webFolder=/home/www
db_name="wwwbackup-incre1"
#定义备份文件名
fileName="${db_name}_${date_now}.tar.gz"
#定义备份文件目录
backUpFileName="${backUpFolder}/${fileName}"
echo "starting backup mysql ${db_name} at ${date_now}."
tar -g tarinfo -czf ${backUpFileName} ${webFolder}
#进入到备份文件目录
find ${backUpFileName} -type f -mtime +7 -exec rm -f {} \;

echo "finish backup webhost ${db_name} at ${date_end}."