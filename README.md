# oci-quickstart-mapr
This is a Terraform module that deploys [MapR](https://mapr.com/products/) on [Oracle Cloud Infrastructure (OCI)](https://cloud.oracle.com/en_US/cloud-infrastructure).  It is developed jointly by Oracle and MapR. For instructions on how to use this material and details on getting support from the vendor that maintains this material, please contact them directly.

## Sizing

|             | Data Nodes   | Bastion Instance |
|-------------|----------------|------------------|
| Recommended | BM.DenseIO2.52 | VM.Standard2.4   | 
| Minimum     | VM.Standard2.16 | VM.Standard2.1   |

## Prerequisites
First off you'll need to do some pre deploy setup.  That's all detailed [here](https://github.com/oracle/oci-quickstart-prerequisites).

## Scaling

Modify the "variables.tf" file prior to deployment and set the number of data nodes to scale your cluster dynamically.

	## Specify number of Data Node Hosts here
	variable "nodecount" { default = "5" }

The above deploys a 5 node cluster.

## Block Volumes
Use of Block Volumes is supported with the example block.tf.NO.  Block Volumes should only be used with BM and VM shapes which do not have local storage.   If you are using DenseIO shapes, DO NOT mix heterogenous storage.

To enable Block Volume use, rename this file to block.tf and Terraform will create and attach Block Volumes which scale with Data Node count.  This template is preconfigured with 12 Block Volumes, defaulting to 1TB in size.   The size can be controlled by modifying the default value in variables.tf.  It is recommended to tailor your Block Volume topology when using VMs to support aggregate IO for your workload.   In practice it's best to have a minimum of 4 Block Volumes at 700GB or greater at a minimum if not using DenseIO shapes.

It is also advised to add the Block Volume attachments as dependencies for remote-exec.tf (in depends_on) to ensure remote execution is not triggered until all Block Volumes are created and attached.

	depends_on = ["oci_core_instance.datanode","oci_core_instance.bastion"]

For 12 Block Volumes, this should be changed to:

	depends_on = ["oci_core_instance.datanode","oci_core_instance.bastion","oci_core_volume_attachment.datanode1","oci_core_volume_attachment.datanode2","oci_core_volume_attachment.datanode3","oci_core_volume_attachment.datanode4","oci_core_volume_attachment.datanode5","oci_core_volume_attachment.datanode6","oci_core_volume_attachment.datanode7","oci_core_volume_attachment.datanode8","oci_core_volume_attachment.datanode9","oci_core_volume_attachment.datanode10","oci_core_volume_attachment.datanode11","oci_core_volume_attachment.datanode12"]

## Password & User Details

Modify the scripts/mapr_setup.sh and scripts/tune.sh to specify passwords for MapR user and MapR Cluster admin.

	## SET PASSWORD HERE
	echo "Somepassword1!" | passwd --stdin mapr

This sets the mapr user password in mapr_setup.sh on the Bastion.

	## SET PASSWORD HERE
	echo "Somep@ssword1" | passwd mapr --stdin

This sets the mapr user password in tune.sh for cluster hosts.


## MapR Version customization

This setup can be customized to use a specific version of MapR.   To do so, a couple modifications will need to be made.  

Modify scripts/mapr_repo_setup.sh to specify which MapR and MEP versions you want to use.
	
	mapr_version="6.0.1"
	MEP_VERSION="5.0.0"

Modify scripts/mapr_advanced_yaml.sh to set these versions.   Pre-configured versions of this script are also included for MapR 6 and MapR 5 - this setup defaults to MapR 6.

	echo "  mapr_core_version: 6.0.1" >> $out
	echo "  mep_version: 5.0.0" >> $out

## Additional deployment customization

Modification of scripts/mapr_advanced_yaml.sh can be done to customize cluster and service layout.   Knowledge of the use of MapR Stanza files is required, otherwise this may break your install.

## Cluster Network Security
By default, the MapR cluster is deployed onto a private subnet which is not directly accessible from the Internet.  If you want to change this, modify terraform/network.tf

	prohibit_public_ip_on_vnic = "true"

Set the above to false, or remove the line entirely.  This will provision Public IPs for each datanode host.

## Deployment

Deploy using standard Terraform commands

	terraform init 
	terraform plan
	terraform apply

This will trigger provisioning and deployment of all elements for the MapR cluster.

## Post Deployment

Post deployment is automated using a scripted process that uses Bash and MapR setup.  Log in to the Bastion host after Terraform completes, then run the following commands to watch installation progress.  The public IP will output as a result of the Terraform completion:

        ssh -i ~/.ssh/id_rsa opc@<public_ip_of_bastion>
        sudo screen -r

Cluster provisioning can take up to 45 minutes.  Output will show on the screen as each step is completed.

## Security and Post-Deployment Auditing

Note that as part of this deployment, ssh keys are used for root level access to provisioned hosts in order to setup software.  The key used is the same as the OPC user which has super-user access to the hosts by default.   If enhanced security is desired, then the following steps should be taken after the Cluster is up and running:

Remove ssh private keys from the Bastion host

        rm -f /home/opc/.ssh/id_rsa

Replace the authorized_keys file in /root/.ssh/ on all hosts with the backup copy

        sudo mv /root/.ssh/authorized_keys.bak /root/.ssh/authorized_keys

## MapR UI Access
Access to the UI can be done either using SSH tunnels through the Bastion host, or if the datanodes have Internet IPs, then direct access is possible.   By default, MCS is deployed to the second datanode of the cluster.
