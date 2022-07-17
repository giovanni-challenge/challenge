provider "kubernetes" {
  config_path = "../20_create_cluster/cluster.kubeconfig"
}

resource "kubernetes_namespace" "kiratech" {

  metadata {
    name = "kiratech-test"
  }
}

resource "kubernetes_job" "kube-bench" {

  count = 3

  metadata {
    name = "kube-bench-${count.index}"
    labels = {
      app = "kube-bench-${count.index}"
    }
  }

  spec {
    template {
      metadata {}
      spec {
        host_pid = true
        node_name = "vm${count.index}"
        toleration {
          key = "node-role.kubernetes.io/master"
          operator = "Exists"
          effect = "NoSchedule"
        }
        container {

          name    = "kube-bench"
          image   = "docker.io/aquasec/kube-bench:v0.6.8"
          command = ["kube-bench"]
          volume_mount {
            name       = "var-lib-etcd"
            mount_path = "/var/lib/etcd"
            read_only  = true
          }

          volume_mount {
            name       = "var-lib-kubelet"
            mount_path = "/var/lib/kubelet"
            read_only  = true
          }

          volume_mount {
            name       = "var-lib-kube-scheduler"
            mount_path = "/var/lib/kube-scheduler"
            read_only  = true
          }

          volume_mount {
            name       = "var-lib-kube-controller-manager"
            mount_path = "/var/lib/kube-controller-manager"
            read_only  = true
          }

          volume_mount {
            name       = "etc-systemd"
            mount_path = "/etc/systemd"
            read_only  = true
          }

          volume_mount {
            name       = "lib-systemd"
            mount_path = "/lib/systemd/"
            read_only  = true
          }

          volume_mount {
            name       = "srv-kubernetes"
            mount_path = "/srv/kubernetes/"
            read_only  = true
          }

          volume_mount {
            name       = "etc-kubernetes"
            mount_path = "/etc/kubernetes"
            read_only  = true
          }

          volume_mount {
            name       = "usr-bin"
            mount_path = "/usr/local/mount-from-host/bin"
            read_only  = true
          }

          volume_mount {
            name       = "etc-cni-netd"
            mount_path = "/etc/cni/net.d/"
            read_only  = true
          }

          volume_mount {
            name       = "opt-cni-bin"
            mount_path = "/opt/cni/bin/"
            read_only  = true
          }

        }

        restart_policy = "Never"
        volume {
          name = "var-lib-etcd"
          host_path {
            path = "/var/lib/etcd"
          }
        }

        volume {
          name = "var-lib-kubelet"
          host_path {
            path = "/var/lib/kubelet"
          }
        }

        volume {
          name = "var-lib-kube-scheduler"
          host_path {
            path = "/var/lib/kube-scheduler"
          }
        }

        volume {
          name = "var-lib-kube-controller-manager"
          host_path {
            path = "/var/lib/kube-controller-manager"
          }
        }

        volume {
          name = "etc-systemd"
          host_path {
            path = "/etc/systemd"
          }
        }

        volume {
          name = "lib-systemd"
          host_path {
            path = "/lib/systemd"
          }
        }

        volume {
          name = "srv-kubernetes"
          host_path {
            path = "/srv/kubernetes"
          }
        }

        volume {
          name = "etc-kubernetes"
          host_path {
            path = "/etc/kubernetes"
          }
        }

        volume {
          name = "usr-bin"
          host_path {
            path = "/usr/bin"
          }
        }

        volume {
          name = "etc-cni-netd"
          host_path {
            path = "/etc/cni/net.d/"
          }
        }

        volume {
          name = "opt-cni-bin"
          host_path {
            path = "/opt/cni/bin/"
          }
        }

      }
    }
  }
}

