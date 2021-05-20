# Terraform Block
terraform {
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"    # Official OpenStack Provider
    }
  }
}

# Configure the OpenStack Provider
provider "openstack" {
  user_name   = "admin"                    # Change to the email you enrolled with
  password    = "team_cengn"                          # Passwords will always be "password"
  auth_url    = "http://openstack.local/identity"   # URL of the OpenStack Authentication API
}

# Instance Block
resource "openstack_compute_instance_v2" "instance" {
  name        = "instance-1"
  image_name  = "debian"
  flavor_name = "small"
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
    host = openstack_compute_floatingip_associate_v2.floatip_instance.floating_ip
  }
}

# Floating IP Block
resource "openstack_networking_floatingip_v2" "floatip" {
  pool = "public"
}
 
# Floating IP Association Block
resource "openstack_compute_floatingip_associate_v2" "floatip_instance" {
  floating_ip = openstack_networking_floatingip_v2.floatip.address
  instance_id = openstack_compute_instance_v2.instance.id
}

