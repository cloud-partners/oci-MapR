#!/bin/bash
## cloud-init bootstrap script
## Stop SSHD to prevent remote execution during this process
systemctl stop sshd
if [ -f /etc/selinux/config ]; then 
	selinuxchk=`sudo cat /etc/selinux/config | grep enforcing`
	selinux_chk=`echo -e $?`
	if [ $selinux_chk = "0" ]; then
		sudo sed -i.bak 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
	fi
fi

## Custom Boot Volume Extension
sudo yum -y install cloud-utils-growpart screen.x86_64
sudo yum -y install gdisk
echo "0" > /home/opc/.done
sudo reboot
