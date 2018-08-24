# Output the private and public IPs of the instance

output "INFO - Data Node Shape" { 
  value = "${var.DataNodeInstanceShape}\n"
}

output "1 - Bastion SSH Login" { 
  value = <<END

	ssh -i ~/.ssh/id_rsa opc@${data.oci_core_vnic.bastion_vnic.public_ip_address}

END
}

output "2 - Bastion Commands after SSH login" {
  value = <<END

	sudo su -
	screen -r

END
}

