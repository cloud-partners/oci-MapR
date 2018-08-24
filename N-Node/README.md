# Usage Guide

## PREREQUISITES

Installation has a dependency on Terraform being installed and configured for the user tenancy.   As such an "env-vars" file is included with this package that contains all the necessary environment variables.  This file should be updated with the appropriate values prior to installation.  To source this file prior to installation, either reference it in your .rc file for your shell's or run the following:

        source env-vars

## Scaling 

Modify the env-vars file prior to deployment and modify the number of data nodes to scale your cluster dynamically.

## Password & User Details

Modify the scripts/mapr_setup.sh and scripts/tune.sh to specify passwords for MapR user and MapR Cluster admin.

## MapR Version customization

This setup can be customized to use a specific version of MapR.   To do so, a couple modifications will need to be made.  

* Modify scripts/mapr_repo_setup.sh to specify which MapR and MEP versions you want to use.
* Modify scripts/mapr_advanced_yaml.sh to set these versions.   Pre-configured versions of this script are also included for MapR 6 and MapR 5 - this setup defaults to MapR 6.

## Additional deployment customization

Modification of scripts/mapr_advanced_yaml.sh can be done to customize cluster and service layout.   Knowledge of the use of MapR Stanza files is required, otherwise this may break your install.

## Deployment

Deploy using standard Terraform commands

        terraform init && terraform plan && terraform apply

## Post Deployment

Post deployment is automated using a scripted process that uses Bash and MapR setup.  Log in to the Bastion host after Terraform completes, then run the following commands to watch installation progress.  The public IP will output as a result of the Terraform completion:

        ssh -i ~/.ssh/id_rsa opc@<public_ip_of_bastion>
        sudo screen -r

Cluster provisioning can take up to 45 minutes.

## Security and Post-Deployment Auditing

Note that as part of this deployment, ssh keys are used for root level access to provisioned hosts in order to setup software.  The key used is the same as the OPC user which has super-user access to the hosts by default.   If enhanced security is desired, then the following steps should be taken after the Cluster is up and running:

Remove ssh private keys from the Bastion and Utility hosts

        rm -f /home/opc/.ssh/id_rsa

Replace the authorized_keys file in /root/.ssh/ on all hosts with the backup copy

        sudo mv /root/.ssh/authorized_keys.bak /root/.ssh/authorized_keys
