#!/bin/bash

## Install Java
yum install java-1.8.0-openjdk.x86_64 java-1.8.0-openjdk-devel.x86_64 ntp -y
systemctl stop chronyd
systemctl disable chronyd
sudo cat /etc/ntp.conf | grep -iv rhel >> /tmp/ntp.conf
echo "server 169.254.169.254 iburst" >> /tmp/ntp.conf
sudo cp /tmp/ntp.conf /etc/ntp.conf
sudo rm -f /tmp/ntp.conf
systemctl stop ntpd
sudo ntpdate 169.254.169.254
systemctl start ntpd
systemctl enable ntpd
