#!/bin/bash

for i in $(seq 0 2); do
  ip=$(terraform output -json | jq -r ".ip.value[$i]") yq -i ".vms.hosts.vm$i.ansible_host=env(ip)" ../10_configure_vms/hosts.yaml
done

