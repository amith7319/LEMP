#!/bin/bash
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi
yum update -y
yum upgrade -y
yum install wget epel-release curl nano -y
if [ ! -x /usr/sbin/nginx ];
    then
        echo "NGINX is being INSTALLED" && yum install nginx -y && systemctl start nginx && systemctl enable nginx
    else
        systemctl restart nginx && echo "NGINX is INSTALLED and RUNNING"
fi
