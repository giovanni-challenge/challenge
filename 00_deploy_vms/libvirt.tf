resource "libvirt_volume" "ubuntu-qcow2" {
  count  = 3
  name   = "ubuntu${count.index}.qcow2"
  pool   = "default"
  source = "../images/ubuntu-20.04-server-cloudimg-amd64-disk-kvm.img"
  format = "qcow2"
}

data "template_file" "user_data" {
  template = file("${path.module}/cloud_init.cfg")
}

resource "libvirt_cloudinit_disk" "commoninit" {
  name      = "commoninit.iso"
  pool      = "default"
  user_data = data.template_file.user_data.rendered
}

resource "libvirt_domain" "ubuntu" {

  count = 3

  name   = "ubuntu ${count.index}"
  memory = "3072"
  vcpu   = 2

  network_interface {
    network_name   = "default"
    wait_for_lease = true
  }

  disk {
    volume_id = libvirt_volume.ubuntu-qcow2[count.index].id
  }

  cloudinit = libvirt_cloudinit_disk.commoninit.id

  console {
    type        = "pty"
    target_type = "serial"
    target_port = "0"
  }

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }
}

output "ip" {
  value = libvirt_domain.ubuntu.*.network_interface.0.addresses.0
}
