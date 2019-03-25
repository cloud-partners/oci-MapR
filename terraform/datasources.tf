# Gets a list of Availability Domains
data "oci_identity_availability_domains" "ADs" {
  compartment_id = "${var.tenancy_ocid}"
}

# Get list of VNICS for Bastion 
data "oci_core_vnic_attachments" "bastion_vnics" {
  compartment_id      = "${var.compartment_ocid}"
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[var.AD - 1],"name")}"
  instance_id = "${oci_core_instance.bastion.id}"
}

# Get VNIC ID for first VNIC on Bastion 
data "oci_core_vnic" "bastion_vnic" {
  vnic_id = "${lookup(data.oci_core_vnic_attachments.bastion_vnics.vnic_attachments[0],"vnic_id")}"
}

resource "oci_core_private_ip" "bastion_private_ip" {
  vnic_id = "${lookup(data.oci_core_vnic_attachments.bastion_vnics.vnic_attachments[0],"vnic_id")}"
  display_name = "bastion_private_ip"
}

# Get list of VNICS for Datanodes
data "oci_core_vnic_attachments" "datanode_vnics" {
  count = "${var.nodecount}"
  compartment_id      = "${var.compartment_ocid}"
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[var.AD - 1],"name")}"
  instance_id = "${oci_core_instance.datanode.*.id[count.index]}"
}

# Get VNIC ID for relevant Datanodes
#data "oci_core_vnic" "datanode1_vnic" {
#  vnic_id = "${lookup(data.oci_core_vnic_attachments.datanode_vnics.0.vnic_attachments[0],"vnic_id")}"
#}
#
#data "oci_core_vnic" "datanode2_vnic" {
#  vnic_id = "${lookup(data.oci_core_vnic_attachments.datanode_vnics.1.vnic_attachments[0],"vnic_id")}"
#}

