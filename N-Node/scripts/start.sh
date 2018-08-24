#!/bin/bash
## First Script called on Bastion Host after TF Deployment
## This script drives entire cluster setup process, invokes sub scripts in screen sessions 
sudo sed -i 's/1000/10000/g' /etc/screenrc
sudo tee -a ~/.screenrc << EOF
screen -t setup 
select 0
screen -t logwatch
select 1

altscreen on
term screen-256color
bind ',' prev
bind '.' next

hardstatus alwayslastline
hardstatus string '%{= kG}[ %{G}%H %{g}][%= %{= kw}%?%-Lw%?%{r}(%{W}%n*%f%t%?(%u)%?%{r})%{w}%?%+Lw%?%?%= %{g}][%{B} %m-%d %{W}%c %{g}]'
EOF
sudo tee -a /etc/screenrc << EOF
caption always "%{= bb}%{+b w}%n %t %h %=%l %H %c"
hardstatus alwayslastline "%-Lw%{= BW}%50>%n%f* %t%{-}%+Lw%<"
activity "Activity in %t(%n)"

shelltitle "shell"
shell -$SHELL
EOF
echo -e "Starting Master Cluster Provisioning Process"
sudo screen -dmLS bastion 
sleep .001
## Start Bastion setup script
sudo screen -S bastion -t setup -X stuff '/home/opc/bastion.sh\n'
