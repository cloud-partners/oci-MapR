#!/bin/bash
for host in `cat host_list`; do 
	ssh -oBatchMode=yes -oStrictHostKeyChecking=no -i /home/opc/.ssh/id_rsa $host 'mkdir -p /opt/mapr'
done;
wget http://package.mapr.com/releases/installer/mapr-setup.sh -P /tmp
chmod +x /tmp/mapr-setup.sh
/tmp/mapr-setup.sh -y install
## SET PASSWORD HERE
echo "Somepassword1!" | passwd --stdin mapr
## Generate Advanced YAML configuration for use with MapR Setup
/home/opc/mapr_advanced_yaml.sh
mkdir -p /home/mapr/.ssh
cp /home/opc/.ssh/id_rsa /home/mapr/.ssh/id_rsa
chown -R mapr:mapr /home/mapr/.ssh/
sudo -u mapr screen -dmLS Setup
sleep 15
## SET PASSWORD FROM ABOVE TO MATCH HERE -u mapr:<password>
sudo -u mapr screen -S Setup -X stuff '/opt/mapr/installer/bin/mapr-installer-cli install -nvf -t /opt/mapr/installer/mapr_advanced.yaml -u mapr:Somepassword1\!@mapr-bastion:9443 -o config.cluster_admin_password=mapr\n'
sudo -u mapr screen -S Setup -X stuff 'touch /home/mapr/.done\n'
