resource "oci_core_instance" "bastion" {
  count = "1"
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[var.AD - 1],"name")}"
  compartment_id      = "${var.compartment_ocid}"
  display_name        = "MapR Bastion"
  hostname_label      = "MapR-Bastion"
  shape               = "${var.BastionInstanceShape}"
  subnet_id = "${oci_core_subnet.bastion.*.id[var.AD - 1]}"

  source_details {
    source_type = "image"
    source_id = "${var.InstanceImageOCID[var.region]}"
    boot_volume_size_in_gbs = "${var.boot_volume_size}"
  }

  metadata {
    ssh_authorized_keys = "${var.ssh_public_key}"
    user_data = "${base64encode(file("scripts/boot.sh"))}"
  }

  timeouts {
    create = "30m"
  }
}

resource "oci_core_instance" "datanode" {
  count = "${var.nodecount}"
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[var.AD - 1],"name")}"
  compartment_id      = "${var.compartment_ocid}"
  display_name        = "MapR Data Node ${format("%01d", count.index+1)}"
  hostname_label      = "MapR-DataNode-${format("%01d", count.index+1)}"
  shape               = "${var.DataNodeInstanceShape}"
  subnet_id           = "${oci_core_subnet.private.*.id[var.AD - 1]}"

  source_details {
    source_type = "image"
    source_id = "${var.InstanceImageOCID[var.region]}"
    boot_volume_size_in_gbs = "${var.boot_volume_size}"
  }

  metadata {
    ssh_authorized_keys = "${var.ssh_public_key}"
    user_data = "${base64encode(file("scripts/boot.sh"))}"
  }

  timeouts {
    create = "30m"
  }
}
