#!/bin/bash
## Node Tuning Script

## MapR Setup
groupadd -g 5000 mapr
useradd -u 5000 -g 5000 mapr
## SET PASSWORD HERE
echo "Somep@ssword1" | passwd mapr --stdin
mkdir -p /home/mapr/.ssh/
cp /home/opc/.ssh/authorized_keys /home/mapr/.ssh/
chown -R mapr:mapr /home/mapr/.ssh/
echo "mapr    ALL=(ALL)       ALL"

## Add limits for mapr user
echo "mapr    - nofile 64000" >> /etc/security/limits.conf
echo "mapr    - nproc  64000" >> /etc/security/limits.d/90-nproc.conf

## Disable Transparent Huge Pages
echo never | tee -a /sys/kernel/mm/transparent_hugepage/enabled
echo "echo never | tee -a /sys/kernel/mm/transparent_hugepage/enabled" | tee -a /etc/rc.local

## Set vm.swappiness to 1
echo vm.swappiness=1 | tee -a /etc/sysctl.conf
echo 1 | tee /proc/sys/vm/swappiness

## Tune system network performance
echo net.ipv4.tcp_timestamps=0 >> /etc/sysctl.conf
echo net.ipv4.tcp_sack=1 >> /etc/sysctl.conf
echo net.core.rmem_max=4194304 >> /etc/sysctl.conf
echo net.core.wmem_max=4194304 >> /etc/sysctl.conf
echo net.core.rmem_default=4194304 >> /etc/sysctl.conf
echo net.core.wmem_default=4194304 >> /etc/sysctl.conf
echo net.core.optmem_max=4194304 >> /etc/sysctl.conf
echo net.ipv4.tcp_rmem="4096 87380 4194304" >> /etc/sysctl.conf
echo net.ipv4.tcp_wmem="4096 65536 4194304" >> /etc/sysctl.conf
echo net.ipv4.tcp_low_latency=1 >> /etc/sysctl.conf

## Tune File System options
sed -i "s/defaults        1 1/defaults,noatime        0 0/" /etc/fstab

## Enable root login via SSH key
sudo cp /root/.ssh/authorized_keys /root/.ssh/authorized_keys.bak
sudo cp /home/opc/.ssh/authorized_keys /root/.ssh/authorized_keys

