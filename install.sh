#!/bin/bash
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi
yum update -y
yum install wget epel-release curl nano -y
if [ ! -x /usr/sbin/nginx ];
    then
        echo "NGINX is being INSTALLED" && yum install nginx -y && systemctl start nginx && systemctl enable nginx
    else
        systemctl restart nginx && echo "NGINX is INSTALLED and RUNNING"
fi

## Installing Mariadb

yum -y install mariadb mariadb-server
systemctl start mariadb && systemctl enable mariadb
VERSION=`mysql -V |awk '{print $5}' |sed "s/-[[:alpha:]].*$//"`
if [ -z "`mysql -V |grep -i mariadb`" ]; then
   echo MYSQL VERSION IS $VERSION
fi
password=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 20 | head -n 1)
echo Mysql root password = $password > /root/LEMPpassword.txt
mysql_secure_installation <<EOF

y
$password
$password
y
n
y
y
EOF

## Installing PHP

if [ ! -x /usr/bin/php ];
   then
      yum install http://rpms.remirepo.net/enterprise/remi-release-7.rpm -y
      yum --disablerepo="*" --enablerepo="remi-safe" list php[7-9][0-9].x86_64 |grep php
      echo #############################################################################
      read -p "Select one PHP version from above...like php70,php71,php80  " phpv
      echo #############################################################################
      yum-config-manager --enable remi-$phpv
      yum install php php-common php-mbstring php-gd php-intl php-xml php-json php-mysqlnd php-fpm -y
   else
      echo "PHP is already installed"
fi
sed 's/user = apache/user = nginx/g' /etc/php-fpm.d/www.conf
sed 's/group = apache/group = nginx/g' /etc/php-fpm.d/www.conf
systemctl restart php-fpm


