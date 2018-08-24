#!/bin/bash
## Bastion script to drive all provisioning tasks 
##

## SSH Functions
ssh_cmd () {
        ssh -o BatchMode=yes -o StrictHostkeyChecking=no -i /home/opc/.ssh/id_rsa $1@${host} $2
}

scp_cmd () {
        scp -o BatchMode=yes -o StrictHostkeyChecking=no -i /home/opc/.ssh/id_rsa $2 $1@${host}:$3
}

ssh_check () {
        ssh_chk="1"
        if [ -z $user ]; then
                user="opc"
        fi
        echo -ne "Checking SSH as $user on ${hostfqdn} [*"
        while [ "$ssh_chk" != "0" ]; do
                ssh_chk=`ssh -o StrictHostKeyChecking=no -q -i /home/opc/.ssh/id_rsa ${user}@${hostfqdn} 'cat /home/opc/.done'`
                if [ -z $ssh_chk ]; then
                        continue
                elif [ $ssh_chk = "0" ]; then
                        continue
                else
                        echo "DEBUG OUTPUT - $ssh_chk"
                fi
                sleep 5
                echo -n "*"
        done;
        echo -ne "*] - DONE\n"
        unset sshchk 
        unset user
}

### Firewall Configuration
start_time=`date +%Y-%m%d-%H:%M:%S`
start_time_s=`date +%H:%M:%S`
## Set this flag to 1 to enable host firewalls, 0 to disable
firewall_on="0"
### Main execution below this point - all tasks are initiated from Bastion host inside screen session ##
cd /home/opc/
./iscsi.sh
mv /root/.ssh/authorized_keys /root/.ssh/authorized_keys.bak
cp /home/opc/.ssh/authorized_keys /root/.ssh/authorized_keys
## Set DNS to resolve all subnet domains
rm -f /etc/resolv.conf
echo "search public1.maprvcn.oraclevcn.com public2.maprvcn.oraclevcn.com public3.maprvcn.oraclevcn.com private1.maprvcn.oraclevcn.com private2.maprvcn.oraclevcn.com private3.maprvcn.oraclevcn.com bastion1.maprvcn.oraclevcn.com bastion2.maprvcn.oraclevcn.com bastion3.maprvcn.oraclevcn.com" > /etc/resolv.conf
echo "nameserver 169.254.169.254" >> /etc/resolv.conf

## Continue with Main Setup
if [ -f host_list ]; then 
	rm -f host_list;
	rm -f datanodes;
	rm -f hosts;
fi 
domain="maprvcn.oraclevcn.com"
ct=1;
dn_count=0; 
while [ $ct -lt 1000 ]; do
        nslk=`nslookup mapr-datanode-${ct}`
        ns_ck=`echo -e $?`
        if [ $ns_ck = 0 ]; then
		hname=`nslookup mapr-datanode-${ct} | grep Name | gawk '{print $2}'`
		echo "$hname" >> host_list;
		echo "$hname" >> datanodes;
		dn_count=$((dn_count+1))
        else
                break
        fi
        ct=$((ct+1));
done;
echo "127.0.0.1   localhost" > hosts
for host in `cat host_list`; do 
	h_ip=`dig +short $host`
	echo -e "$h_ip\t$host" >> hosts
done;
for host in `cat host_list | gawk -F '.' '{print $1}'`; do
        echo -e "\tConfiguring $host for deployment."
        host_ip=`cat hosts | grep $host | gawk '{print $1}'`
        ssh_check
        echo -ne "*] [OK]\n\tCopying Setup Scripts...\n"
        ## Copy Setup scripts
	scp_cmd opc "/home/opc/hosts" "~/"
	scp_cmd opc "/home/opc/iscsi.sh" "~/"
	scp_cmd opc "/home/opc/node_prep.sh" "~/"
	scp_cmd opc "/home/opc/tune.sh" "~/"
	scp_cmd opc "/home/opc/prereqs.sh" "~/"
        ## Set Execute Flag on scripts
        ssh -o BatchMode=yes -o StrictHostKeyChecking=no -i /home/opc/.ssh/id_rsa opc@$host 'chmod +x *.sh'
        ## Execute Node Prep
	ssh_cmd opc 'sudo ./node_prep.sh &'
	ssh_cmd opc 'sudo systemctl stop firewalld'
	ssh_cmd opc 'sudo systemctl disable firewalld'
        echo -e "\tDone initializing $host.\n\n"
done;
## End DataNode Node Setup
echo -e "Checking Resources on Data Node..."
wprocs=`ssh -o BatchMode=yes -o StrictHostKeyChecking=no -i /home/opc/.ssh/id_rsa opc@mapr-datanode-1 'cat /proc/cpuinfo | grep processor | wc -l'`
echo -e "$wprocs processors detected.."
ssh -o BatchMode=yes -o StrictHostKeyChecking=no -i /home/opc/.ssh/id_rsa opc@mapr-datanode-1 "free -hg | grep Mem" > /tmp/meminfo
memtotal=`cat /tmp/meminfo | gawk '{print $2}' | cut -d 'G' -f 1`
echo -e "${memtotal}GB of RAM detected..."
ssh -o BatchMode=yes -o StrictHostKeyChecking=no -i /home/opc/.ssh/id_rsa opc@mapr-datanode-1 "cat /proc/partitions | sed 1,2d | grep -iv sda" | gawk '{print $4}' > /tmp/disk_info
disk_count=`cat /tmp/disk_info | wc -l`
echo -e "$disk_count Disks found."

## Finish Cluster Setup Below

mapr_start=`date +%H:%M:%S`
echo -e "\tRunning MapR Repo Setup..."

/home/opc/mapr_repo_setup.sh

for host in `cat host_list | gawk -F '.' '{print $1}'`; do
        echo -e "\tSetting up MapR Repo on ${host}..."
	scp_cmd opc "/home/opc/mapr_bastion.repo" "~/"
	ssh_cmd opc "sudo cp /home/opc/mapr_bastion.repo /etc/yum.repos.d/"
done;

#
# ---- CLUSTER SETUP ----
#

echo -e "\tRunning MapR Cluster Setup."
/home/opc/mapr_setup.sh
echo -e "Open another shell window if you want to see progress: 'Ctrl+a c' then 'sudo su - mapr' then 'screen -r'"
echo -e "Switch between screen windows: 'Ctrl+a <number>' where number is the window number (e.g. this is window 0)\n"
echo -ne "\tWaiting for Cluster Setup to Complete [*"
waiting=0
while [ $waiting = "0" ]; do 
	if [ -f /home/mapr/.done ]; then
		waiting=1
		echo -ne "*] - DONE\n\n"
	else
		echo -ne "*"
		sleep 30
	fi
done;
sleep .001
end_time=`date +%Y-%m%d-%H:%M:%S`
end_time_s=`date +%H:%M:%S` 
mapr_end=`date +%H:%M:%S`
echo -e "\t--CLUSTER SETUP COMPLETE--\n"
echo -e "\t--SUMMARY--"
total1=`date +%s -d ${start_time_s}`
total2=`date +%s -d ${end_time_s}`
totaldiff=`expr ${total2} - ${total1}`
mapr1=`date +%s -d ${mapr_start}`
mapr2=`date +%s -d ${mapr_end}`
maprtotal=`expr ${mapr2} - ${mapr1}`
echo -e "\tMapR Build Took `date +%H:%M:%S -ud @${maprtotal}`"
echo -e "\tEntire Setup Took `date +%H:%M:%S -ud @${totaldiff}`"
