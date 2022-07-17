data "terraform_remote_state" "vms" {
  backend = "local"

  config = {
    path = "../00_deploy_vms/terraform.tfstate"
  }
}

locals {
  master_node  = data.terraform_remote_state.vms.outputs.ip[0]
  worker1_node = data.terraform_remote_state.vms.outputs.ip[1]
  worker2_node = data.terraform_remote_state.vms.outputs.ip[2]
}

resource "null_resource" "k8s_config" {

  provisioner "file" {
    source      = "scripts/common.sh"
    destination = "/tmp/common.sh"

    connection {
      type        = "ssh"
      user        = "challenge"
      private_key = file("${var.ssh_key_path}")
      host        = local.master_node
    }
  }

  provisioner "file" {
    source      = "scripts/master.sh"
    destination = "/tmp/master.sh"

    connection {
      type        = "ssh"
      user        = "challenge"
      private_key = file("${var.ssh_key_path}")
      host        = local.master_node
    }
  }

  provisioner "remote-exec" {
    inline = [
      "bash /tmp/common.sh",
      "bash /tmp/master.sh",
    ]

    connection {
      type        = "ssh"
      user        = "challenge"
      private_key = file("${var.ssh_key_path}")
      host        = local.master_node
    }
  }

  provisioner "local-exec" {
    command = "scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ../challenge challenge@${local.master_node}:/home/challenge/.kube/config cluster.kubeconfig"
  }

  provisioner "local-exec" {
    command = "scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ../challenge challenge@${local.master_node}:/home/challenge/join.sh join.sh"
  }

  provisioner "file" {
    source      = "scripts/common.sh"
    destination = "/tmp/common.sh"

    connection {
      type        = "ssh"
      user        = "challenge"
      private_key = file("${var.ssh_key_path}")
      host        = local.worker1_node
    }
  }

  provisioner "file" {
    source      = "join.sh"
    destination = "/tmp/join.sh"

    connection {
      type        = "ssh"
      user        = "challenge"
      private_key = file("${var.ssh_key_path}")
      host        = local.worker1_node
    }
  }

  provisioner "remote-exec" {
    inline = [
      "bash /tmp/common.sh",
      "sudo bash /tmp/join.sh",
    ]

    connection {
      type        = "ssh"
      user        = "challenge"
      private_key = file("${var.ssh_key_path}")
      host        = local.worker1_node
    }
  }

  provisioner "file" {
    source      = "scripts/common.sh"
    destination = "/tmp/common.sh"

    connection {
      type        = "ssh"
      user        = "challenge"
      private_key = file("${var.ssh_key_path}")
      host        = local.worker2_node
    }
  }

  provisioner "file" {
    source      = "join.sh"
    destination = "/tmp/join.sh"

    connection {
      type        = "ssh"
      user        = "challenge"
      private_key = file("${var.ssh_key_path}")
      host        = local.worker2_node
    }
  }

  provisioner "remote-exec" {
    inline = [
      "bash /tmp/common.sh",
      "sudo bash /tmp/join.sh",
    ]

    connection {
      type        = "ssh"
      user        = "challenge"
      private_key = file("${var.ssh_key_path}")
      host        = local.worker2_node
    }
  }

}

