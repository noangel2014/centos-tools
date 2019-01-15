#!/bin/bash
#阿里Yum源
epel ()
{
yum -y install wget
cd /etc/yum.repos.d/
mkdir bak
mv ./*.repo bak
wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo
yum clean all && yum makecache
}
#基本组件安装
base_install ()
{
yum install net-tools lrzsz gcc gcc-c++ make cmake libxml2-devel openssl-devel curl curl-devel unzip sudo ntp libaio-devel wget vim ncurses-devel autoconf automake zlib-devel  python-devel python-pip iftop ntp iotop lsof python-pip vim telnet  -y
}

#开启包转发
ip_forward ()
{
echo "1" > /proc/sys/net/ipv4/ip_forward
echo "net.ipv4.ip_forward = 1"  >> /usr/lib/sysctl.d/00-system.conf
}

#selinux
selinux ()
{
setenforce 0
sed -i  "s/enforcing/disabled/" /etc/sysconfig/selinux
}

#ssh服务安全配置
sshd ()
{
tee -a  /etc/ssh/sshd_config << EOF
Port 13389 #修改默认ssh端口
UseDNS no #不适用DNS解析
EOF
systemctl restart sshd
}

#时间同步
ntpdate ()
{
/usr/sbin/ntpdate pool.ntp.org
echo "* */5 * * * /usr/sbin/ntpdate pool.ntp.org > /dev/null 2>&1" >> /var/spool/cron/root;chmod 600 /var/spool/cron/root
}

ulimit ()
{
#最大文件描述符
echo "ulimit -SHn 102400" >> /etc/rc.local
cat >> /etc/security/limits.conf << EOF
 *           soft   nofile       102400
 *           hard   nofile       102400
 *           soft   nproc        102400
 *           hard   nproc        102400
EOF
}

#内核参数优化
kernel ()
{
cp /etc/sysctl.conf /et/sysctl.conf.bak
cat > /etc/sysctl.conf << EOF
 net.ipv4.ip_forward = 0
 net.ipv4.conf.default.rp_filter = 1
 net.ipv4.conf.default.accept_source_route = 0
 kernel.sysrq = 0
 kernel.core_uses_pid = 1
 net.ipv4.tcp_syncookies = 1
 kernel.msgmnb = 65536
 kernel.msgmax = 65536
 kernel.shmmax = 68719476736
 kernel.shmall = 4294967296
 net.ipv4.tcp_max_tw_buckets = 6000
 net.ipv4.tcp_sack = 1
 net.ipv4.tcp_window_scaling = 1
 net.ipv4.tcp_rmem = 4096 87380 4194304
 net.ipv4.tcp_wmem = 4096 16384 4194304
 net.core.wmem_default = 8388608
 net.core.rmem_default = 8388608
 net.core.rmem_max = 16777216
 net.core.wmem_max = 16777216
 net.core.netdev_max_backlog = 262144
 net.core.somaxconn = 262144
 net.ipv4.tcp_max_orphans = 3276800
 net.ipv4.tcp_max_syn_backlog = 262144
 net.ipv4.tcp_timestamps = 0
 net.ipv4.tcp_synack_retries = 1
 net.ipv4.tcp_syn_retries = 1
 net.ipv4.tcp_tw_recycle = 1
 net.ipv4.tcp_tw_reuse = 1
 net.ipv4.tcp_mem = 94500000 915000000 927000000
 net.ipv4.tcp_fin_timeout = 1
 net.ipv4.tcp_keepalive_time = 1200
 net.ipv4.ip_local_port_range = 1024 65535
EOF
/sbin/sysctl -p
}

#pip源
pip ()
{
if [ ! -d ~/.pip ]
then
mkdir ~/.pip
fi
if [ ! -f ~/.pip/pip.conf ]
then
tee ~/.pip/pip.conf < EOF
[global]
index-url = http://mirrors.aliyun.com/pypi/simple/

[install]
trusted-host=mirrors.aliyun.com
EOF
pip install --upgrade pip
fi
}

epel
base_install
ip_forward
selinux
sshd
ntpdate
ulimit
kernel
pip