# Challenge

The VM provisioning is performed through Terraform, it is free and it is a widely known and adopted tools for IaC with several providers. VMs will run on KVM.

## Initial steps
Move to the "images" folder and download and resize the Ubuntu server image:
```bash
cd images
wget https://cloud-images.ubuntu.com/releases/focal/release/ubuntu-20.04-server-cloudimg-amd64-disk-kvm.img
qemu-img resize ubuntu-20.04-server-cloudimg-amd64-disk-kvm.img 15G
```

Move back to the project's root and create a new key pair that will also be configured in cloud-init
```bash
cd ..
ssh-keygen -t rsa -f challenge -N "" -C challenge
key=$(cat challenge.pub) yq -i '.users[0].ssh_authorized_keys[0] = env(key)' 00_deploy_vms/cloud_init.cfg
```

## VM Provisioning
```bash
cd 00_deploy_vms/
terraform init
terraform apply
./update_ansible_inventory.sh
```

## VM Configuration
```bash
cd ../10_configure_vms/
ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i hosts.yaml basic_config.yaml
```

## Kubernetes Cluster Installation and Configuration
Note: some minutes might be required before the last command reports all the three nodes as "Ready"
```bash
cd ../20_create_cluster/
terraform init
terraform apply
kubectl --kubeconfig=cluster.kubeconfig get nodes
```

## Kubernetes Security Benchmark
Kube-bench from Aqua (https://github.com/aquasecurity/kube-bench) has been chosen as a security benchmark tool; it is free and its usage has already been part of many Kubernetes security courses. It implements the guidelines provided by the well-recognized CIS Kubernetes benchmark (https://www.cisecurity.org/benchmark/kubernetes/)
The benchmark will run as three jobs (one per node)
```bash
cd ../30_create_ns_run_benchmark/
terraform init
terraform apply
```
Also, this step creates the "kiratech-test" namespace

## Helm application
The robot-shop sample application (https://github.com/instana/robot-shop) will be deployed
```bash
cd ../40_deploy_application/
git clone https://github.com/instana/robot-shop
cp redis-statefulset-patched.yaml robot-shop/K8s/helm/templates/redis-statefulset.yaml
helm --kubeconfig ../20_create_cluster/cluster.kubeconfig install --create-namespace --namespace robot-shop myrobot-shop robot-shop/K8s/helm --set image.version=2.0.2 --set nodeport=true
```

Reach the web service at `http://$IP:$PORT/` where:

```bash
IP=$(kubectl --kubeconfig=../20_create_cluster/cluster.kubeconfig -n robot-shop get node vm0 -o json | jq -r '.status.addresses[0].address')
PORT=$(kubectl --kubeconfig=../20_create_cluster/cluster.kubeconfig -n robot-shop get svc web -o json | yq -r '.spec.ports[0].nodePort')
```

## CI Lint
Lint checks are performed in CI through Github Actions, the config can be found in `.github/workflows/lint.yaml`
