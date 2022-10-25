#!/bin/bash
#
# Script to perform the initial ansible provisioing steps
#
# Called by /root/h_bootstrap.sh which is created by the userdata script
# in the terraform managment module.

set -eu pipefail


function report() {
  local message=$1

  if [ -t 1 ]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') $message"
  else
    logger "$message"
  fi
}


function exit_if_provisioned() {
  local status_file="/usr/local/share/h_status.json"

  if [ -f $status_file ] ; then
    report "Already provisioned. To reprovision remove: $status_file"
    exit 0
  fi
  report "provisioning host"
}


function set_facts() {
  local environment="$(awk 'BEGIN {FS="-"} {print $1}' <(hostname))"
  local output_file="/etc/ansible/facts.d/identity.fact"
  local metadata="$(curl -s \
       http://169.254.169.254/latest/dynamic/instance-identity/document)"

  if [[ -z $metadata ]] ; then
    report "set_facts failed: EC2 Metadata unavailable."
  fi

  mkdir -p /etc/ansible/facts.d

  local accountId="$(jq --raw-output .accountId <(echo "${metadata}"))"
  local architecture="$(jq --raw-output .architecture <(echo "${metadata}"))"
  local availabilityZone="$(jq --raw-output .availabilityZone <(echo "${metadata}"))"
  local imageId="$(jq --raw-output .imageId <(echo "${metadata}"))"
  local instanceId="$(jq --raw-output .instanceId <(echo "${metadata}"))"
  local instanceType="$(jq --raw-output .instanceType <(echo "${metadata}"))"
  local privateIp="$(jq --raw-output .privateIp <(echo "${metadata}"))"
  local region="$(jq --raw-output .region <(echo "${metadata}"))"

  echo '[localfacts]' > ${output_file}

  echo "accountId = ${accountId}" >> ${output_file}
  echo "architecture = ${architecture}" >> ${output_file}
  echo "availabilityZone = ${availabilityZone}" >> ${output_file}
  echo "imageId = ${imageId}" >> ${output_file}
  echo "instanceId = ${instanceId}" >> ${output_file}
  echo "instanceType = ${instanceType}" >> ${output_file}
  echo "privateIp = ${privateIp}" >> ${output_file}
  echo "region = ${region}" >> ${output_file}

  echo "env = ${environment}" >> ${output_file}

  chown -R ansible /etc/ansible/
}


function provision_host_with_ansible() {
  local ansible_inventory="/usr/local/share/ansible_inventory"
  local playbook="/usr/local/share/report/terraform/modules/report/ec2/ansible/provision.yml"

  echo $HOSTNAME > $ansible_inventory
  ansible-playbook --connection=local -i $ansible_inventory $playbook
}


function update_status() {
  local value="${1:-provisioned}"
  local status_file="/usr/local/share/h_status.json"

  echo "{"status": "$value"}" > $status_file
  report "provisioning complete"
  exit 0
}


function init() {
  exit_if_provisioned
  set_facts
  provision_host_with_ansible
  update_status
}


init
