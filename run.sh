#!/bin/bash

get_instance_id(){
  local instance_hostname="${1}"
  local instance_id=$(aws ec2 describe-instances --filter "Name=private-dns-name,Values=${instance_hostname}" | jq -r '.Reservations[].Instances[].InstanceId')

  echo "$instance_id"
}

unregister_instance(){
  local elb_name=$(echo -n "${1}" | tr -d '\n')
  local instance_id="${2}"

  aws elb deregister-instances-from-load-balancer \
    --load-balancer-name "${elb_name}" \
    --instances "${instance_id}"
}

verify_elb_name(){
  if [ -z "${ELB_NAME}" ]; then
    echo 'Missing $ELB_NAME, exiting.'
    exit 1
  fi
}

verify_instance_hostname(){
  if [ -z "${INSTANCE_HOSTNAME}" ]; then
    echo 'Missing $INSTANCE_HOSTNAME, exiting.'
    exit 1
  fi
}

verify_instance_id(){
  local instance_hostname="${1}"
  local instance_id="${2}"

  if [ -z "${instance_id}" ]; then
    echo "Could not get instance id from aws: ${instance_hostname}" 1>&2
    exit 1
  fi
}

main(){
  verify_elb_name
  verify_instance_hostname

  local elb_names_csv="${ELB_NAME}"
  local instance_hostname="${INSTANCE_HOSTNAME}"
  local instance_id=$(get_instance_id "${instance_hostname}")
  verify_instance_id "${instance_hostname}" "${instance_id}"
  local elb_names

  IFS=',' read -rd '' -a elb_names <<<"${elb_names_csv}"

  for elb_name in "${elb_names[@]}"; do
    unregister_instance "${elb_name}" "${instance_id}"
  done
}
main $@
