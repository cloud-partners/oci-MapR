resource "null_resource" "mapr-setup" {
    depends_on = ["oci_core_instance.datanode","oci_core_instance.bastion"]
    provisioner "file" {
      source = "../scripts/"
      destination = "/home/opc/"
      connection {
        agent = false
        timeout = "10m"
        host = "${data.oci_core_vnic.bastion_vnic.public_ip_address}"
        user = "opc"
        private_key = "${var.ssh_private_key}"
    }
    }
    provisioner "file" {
      source = "/home/opc/.ssh/id_rsa"
      destination = "/home/opc/.ssh/id_rsa"
      connection {
        agent = false
        timeout = "10m"
        host = "${data.oci_core_vnic.bastion_vnic.public_ip_address}"
        user = "opc"
        private_key = "${var.ssh_private_key}"
    }
    }
    provisioner "remote-exec" {
      connection {
        agent = false
        timeout = "10m"
        host = "${data.oci_core_vnic.bastion_vnic.public_ip_address}"
        user = "opc"
        private_key = "${var.ssh_private_key}"
      }
      inline = [
	"chown opc:opc /home/opc/.ssh/id_rsa",
	"chmod 0600 /home/opc/.ssh/id_rsa",
	"chmod +x /home/opc/*.sh",
	"/home/opc/start.sh",
	"echo SCREEN SESSION RUNNING ON BASTION AS ROOT"
	]
    }
}

