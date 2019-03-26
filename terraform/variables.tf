###
## Variables here are sourced from env, but still need to be initialized for Terraform
###

variable "tenancy_ocid" {}
variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key_path" {}
variable "region" { default = "us-phoenix-1" }

variable "compartment_ocid" {}
variable "ssh_public_key" {}
variable "ssh_private_key" {}

variable "AD" { default = "2" }

###
## Maintain this mapping as new images come out for each region
###

variable "InstanceImageOCID" {
    type = "map"
    default = {
        // See https://docs.us-phoenix-1.oraclecloud.com/images/
        // Oracle-provided image "CentOS-7.5-2018.06.22-0"
	eu-frankfurt-1 = "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaasdvfvvgzjhqpuwmjbypgovachdgwvcvus5n4p64fajmbassg2pqa"
	us-ashburn-1 = "ocid1.image.oc1.iad.aaaaaaaa5o7kjzy7gqtmu5pxuhnh6yoi3kmzazlk65trhpjx5xg3hfbuqvgq"
	uk-london-1 = "ocid1.image.oc1.uk-london-1.aaaaaaaaa74er3gyrjg3fiesftpc42viplbhp7gdafqzv33kyyx3jrazruta"
	us-phoenix-1 = "ocid1.image.oc1.phx.aaaaaaaapnnv2phiyw7apcgtg6kmn572b2mux56ll6j6mck5xti3aw4bnwrq"
    }
}

###
## BELOW ARE DEFAULT VALUES FOR THIS DEPLOYMENT 
###

## Specify number of Data Node Hosts here
variable "nodecount" { default = "5" }

## Specify the size of each Block Volume attached to Data Node Hosts
variable "blocksize_in_gbs" { default = "1000" }

## Boot Volume Size in GB
variable "boot_volume_size" { default = "256" }

## Set the shape to be used for Bastion Host
variable "BastionInstanceShape" {
  default = "VM.Standard2.8"
}

## Set the shape to be used for Data Node Hosts
variable "DataNodeInstanceShape" {
  default = "BM.DenseIO2.52"
}

###
## End Configuration Customization
###

