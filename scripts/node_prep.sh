#!/bin/bash
## Script to prep each node in the cluster 

## Modify resolv.conf to ensure DNS lookups work
sudo rm -f /etc/resolv.conf
sudo echo "search public1.maprvcn.oraclevcn.com public2.maprvcn.oraclevcn.com public3.maprvcn.oraclevcn.com private1.maprvcn.oraclevcn.com private2.maprvcn.oraclevcn.com private3.maprvcn.oraclevcn.com bastion1.maprvcn.oraclevcn.com bastion2.maprvcn.oraclevcn.com bastion3.maprvcn.oraclevcn.com" > /etc/resolv.conf
sudo echo "nameserver 169.254.169.254" >> /etc/resolv.conf

## Execute screen sessions in parallel
sleep .001
sudo screen -dmLS iscsi
sleep .001
sudo screen -dmLS tune
sleep .001
sudo screen -dmLS prereqs
sleep .001
sudo screen -XS iscsi stuff logfile /home/opc/`date +%Y%m%d`.1.log
sleep .001
sudo screen -XS iscsi stuff login on
sleep .001
sudo screen -XS iscsi stuff log on
sleep .001
sudo screen -XS iscsi stuff logfile flush 1
sleep .001
sudo screen -XS tune stuff logfile /home/opc/`date +%Y%m%d`.2.log
sleep .001
sudo screen -XS tune stuff login on
sleep .001
sudo screen -XS tune stuff log on
sleep .001
sudo screen -XS tune stuff logfile flush 1
sleep .001
sudo screen -XS prereqs stuff logfile /home/opc/`date +%Y%m%d`.3.log
sleep .001
sudo screen -XS prereqs stuff login on
sleep .001
sudo screen -XS prereqs stuff log on
sleep .001
sudo screen -XS prereqs stuff logfile flush 1
sleep .001
## ISCSI device setup
sudo screen -S iscsi -X stuff '/home/opc/iscsi.sh\n'
sleep .001
## OS Tuning parameters
sudo screen -S tune -X stuff '/home/opc/tune.sh\n'
sleep .001
sudo screen -S prereqs -X stuff '/home/opc/prereqs.sh\n'
