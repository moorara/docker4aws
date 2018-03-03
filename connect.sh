#!/bin/bash

#
# This script is used for connecting to docker swarm nodes
#
# USAGE:
#   --access-key         AWS access key id
#   --secret-key         AWS secret access key
#   -r, --region         AWS default region
#   -e, --environment    Environment name
#   -n, --node           manager or worker
#   -a, --action         ssh or tunnel
#
# EXAMPLES:
#   - ./connect.sh --access-key $ACCESS_KEY --secret-key $SECRET_KEY -r $REGION -e $ENVIRONMENT -n manager -a ssh
#   - ./connect.sh --access-key $ACCESS_KEY --secret-key $SECRET_KEY -r $REGION -e $ENVIRONMENT -n manager -a tunnel
#   - ./connect.sh --access-key $ACCESS_KEY --secret-key $SECRET_KEY -r $REGION -e $ENVIRONMENT -n worker  -a ssh
#   - ./connect.sh --access-key $ACCESS_KEY --secret-key $SECRET_KEY -r $REGION -e $ENVIRONMENT -n worker  -a tunnel
#

set -euo pipefail


red='\033[1;31m'
green='\033[1;32m'
yellow='\033[1;33m'
purple='\033[1;35m'
blue='\033[1;36m'
nocolor='\033[0m'

ip_regex=^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$


function whitelist_variable {
  if [[ ! $2 =~ (^|[[:space:]])$3($|[[:space:]]) ]]; then
    printf "${red}Invalid $1 $3${nocolor}\n"
    exit 1
  fi
}

function process_args {
  while [[ $# > 1 ]]; do
    key="$1"
    case $key in
      --access-key)
      access_key="$2"
      shift
      ;;
      --secret-key)
      secret_key="$2"
      shift
      ;;
      -r|--region)
      region="$2"
      shift
      ;;
      -e|--environment)
      environment="$2"
      shift
      ;;
      -n|--node)
      node="$2"
      shift
      ;;
      -a|--action)
      action="$2"
      shift
      ;;
    esac
    shift
  done

  ssh_control_path=$(mktemp -u)
  ssh_key_file=$HOME/.ssh/d4aws-$environment
  ssh_config_file=$HOME/.ssh/d4aws-$environment-config

  whitelist_variable "node" "manager worker" "$node"
  whitelist_variable "action" "ssh tunnel" "$action"
}

function config_aws_cli {
  aws --profile d4aws configure set aws_access_key_id $access_key
  aws --profile d4aws configure set aws_secret_access_key $secret_key
  aws --profile d4aws configure set region $region
  aws --profile d4aws configure set output json
}

function get_node_index {
  json_nodes=$(aws --profile d4aws ec2 describe-instances --filters "Name=tag:Environment,Values=$environment" "Name=tag:swarm-node-type,Values=$node")
  json_nodes=$(echo $json_nodes | jq '[ .Reservations[].Instances[] | select(.State.Name == "running") ]')
  nodes_count=$(echo $json_nodes | jq 'length')

  printf "\n  Index\tNode\t\tPrivate IP\tPublic IP\n"
  for (( i=0; i < $nodes_count; i++ )); do
    private_ip=$(echo $json_nodes | jq -r ".[$i].PrivateIpAddress")
    public_ip=$(echo $json_nodes | jq -r ".[$i].PublicIpAddress")
    printf "  ${green}$i${nocolor}\t${blue}swarm-$node${nocolor}\t${purple}$private_ip${nocolor}\t${yellow}$public_ip${nocolor}\n"
  done
  printf "\n"

  read -p "  Which $node node: " index
  if [[ ! $index =~ ^[0-9]+$ ]] || (( $index < 0 )) || (( $index >= $nodes_count )); then
    printf "\nInvalid $node index $index\n"
    exit 1
  fi

  printf "\n"
}

function get_node_addresses {
  index=$1

  json_content=$(aws --profile d4aws ec2 describe-instances --filters "Name=tag:Name,Values=d4aws-tunnel")
  tunnel_public_ip=$(echo $json_content | jq -r "[ .Reservations[].Instances[] | select(.State.Name == \"running\") | .PublicIpAddress ] | .[0]")

  json_content=$(aws --profile d4aws ec2 describe-instances --filters "Name=tag:Environment,Values=$environment" "Name=tag:swarm-node-type,Values=$node")
  node_private_ip=$(echo $json_content | jq -r "[ .Reservations[].Instances[] | select(.State.Name == \"running\") | .PrivateIpAddress ] | .[$index]")

  if [[ ! $tunnel_public_ip =~ $ip_regex ]]; then
    printf "${red}Tunnel public ip not found!${nocolor}\n"
    exit 1
  elif [[ ! $node_private_ip =~ $ip_regex ]]; then
    printf "${red}$node $index private ip not found!${nocolor}\n"
    exit 1
  fi
}

function create_ssh_config {
  tunnel_public_ip=$1
  node_private_ip=$2

cat > $ssh_config_file <<EOF
Host tunnel
  HostName $tunnel_public_ip
  User admin
  IdentityFile $ssh_key_file
  StrictHostKeyChecking no
  UserKnownHostsFile /dev/null
  LogLevel error
Host $node
  HostName $node_private_ip
  User docker
  IdentityFile $ssh_key_file
  ProxyJump tunnel
  StrictHostKeyChecking no
  UserKnownHostsFile /dev/null
  ControlPath $ssh_control_path
  LogLevel error
EOF
}

function ssh_node {
  ssh -F $ssh_config_file $node
}

function open_docker_tunnel {
  export DOCKER_HOST=127.0.0.1:2374

  ssh \
    -F $ssh_config_file \
    -M -fnNT \
    -L $DOCKER_HOST:/var/run/docker.sock \
    $node
}

function close_docker_tunnel {
  node=$1

  ssh \
    -F $ssh_config_file \
    -O exit $node \
    > /dev/null 2>&1 || true

  unset DOCKER_HOST
  rm -f $ssh_config_file $ssh_control_path > /dev/null 2>&1 || true
}

function run_action {
  case $action in
    ssh)
      ssh_node
      ;;
    tunnel)
      open_docker_tunnel
      PS1="${green}swarm-$node-$index ${blue}> ${nocolor}" bash
      ;;
  esac
}

function cleanup {
  close_docker_tunnel $node || true

  printf "Cleanup completed!\n"
}


trap cleanup EXIT

process_args "$@"
config_aws_cli
get_node_index
get_node_addresses "$index"
create_ssh_config "$tunnel_public_ip" "$node_private_ip"
run_action
