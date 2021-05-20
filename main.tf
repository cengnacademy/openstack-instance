# Terraform Block
terraform {
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
    }
  }
}

# Instance Block
resource "openstack_compute_instance_v2" "example" {
  name        = var.instance_name
  image_name  = var.instance_image
  flavor_name = var.instance_flavor
  key_pair    = "default"
 
  network {
    name = "private"
  }

}

resource "null_resource" "connect" {
  provisioner "remote-exec" {
    inline = [
      "sudo apt install nginx -y"
    ]
  }

  connection {
    type = "ssh"
    user = "debian"
    private_key = file("~/.ssh/id_rsa")
    host = openstack_compute_floatingip_associate_v2.fip_inst.floating_ip
  }
}

# Floating IP Block
resource "openstack_networking_floatingip_v2" "fip" {
  pool = "public"
}
 
# Floating IP Association Block
resource "openstack_compute_floatingip_associate_v2" "fip_inst" {
  floating_ip = openstack_networking_floatingip_v2.fip.address
  instance_id = openstack_compute_instance_v2.example.id
}

