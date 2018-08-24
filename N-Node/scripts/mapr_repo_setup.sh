#!/bin/bash

mapr_version="6.0.1"
MEP_VERSION="3.0.3"
hostname=`hostname`
fqdn=`nslookup ${hostname} | grep Name | gawk '{print $2}'`
yum install httpd lynx createrepo -y
mkdir -p /var/www/html/mapr-bastion-repo
mkdir -p /var/www/html/mapr

echo "[mapr_public_repo] 
name=MapR Public Repo 
baseurl=http://package.mapr.com/releases/v${mapr_version}/redhat/ 
gpgcheck=1 
enabled=1 " >> /etc/yum.repos.d/MapR_Public.repo

yum install --downloadonly --downloaddir=/var/www/html/mapr-bastion-repo/  mapr-hadoop-core mapr-nodemanager mapr-apiserver mapr-posix-client-basic mapr-posix-client-container mapr-zookeeper mapr-core mapr-core-internal mapr-fileserver mapr-librdkafka mapr-loopbacknfs mapr-mapreduce2 mapr-gateway mapr-single-node mapr-historyserver mapr-cldb mapr-webserver mapr-zk-internal mapr-upgrade mapr-posix-client-platinum mapr-resourcemanager mapr-timelineserver mapr-nfs java-1.8.0-openjdk java-1.8.0-openjdk-devel cyrus-sasl-gssapi

yum install --downloadonly --downloaddir=/var/www/html/mapr-bastion-repo/ mapr-client

cd /var/www/html/mapr-bastion-repo
lynx -listonly -dump http://package.mapr.com/releases/MEP/MEP-${MEP_VERSION}/redhat/ >> /tmp/MEP.list
for file in `cat /tmp/MEP.list | sed 1,3d | gawk '{print $2}'`; do 
	wget $file
done;
createrepo .

echo "[mapr_bastion_repo]
name=MapR Bastion Repo
baseurl=http://${fqdn}/mapr-bastion-repo/
gpgcheck=0
enabled=1" >> /home/opc/mapr_bastion.repo

firewall-cmd --zone=public --add-port=80/tcp
firewall-cmd --runtime-to-permanent
systemctl stop httpd.service
systemctl start httpd.service
systemctl status httpd.service

