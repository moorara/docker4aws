#!/bin/bash

#
# This script downloads and prepares Docker CE for AWS latest CloudFormation Template.
#
# USAGE:
#   -c, --channel    Docker CE for AWS channel, stable (default) or edge
#
# EXAMPLES:
#   - ./update.sh
#   - ./update.sh -c stable
#   - ./update.sh --channel edge
#

set -euo pipefail


red='\033[1;31m'
green='\033[1;32m'
yellow='\033[1;33m'
purple='\033[1;35m'
blue='\033[1;36m'
nocolor='\033[0m'

d4aws_file="terraform/d4aws.json"


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
      -c|--channel)
      channel="$2"
      shift
      ;;
    esac
    shift
  done

  channel=${channel:-stable}
  whitelist_variable "channel" "stable edge" "$channel"
}

function download_d4aws {
  channel="$1"
  if [[ "$channel" != "stable" && "$channel" != "edge" ]]; then
    printf "${red}Channel $channel is not valid.${nocolor}\n"
    exit 1
  fi

  curl -sSL "https://editions-us-east-1.s3.amazonaws.com/aws/$channel/Docker-no-vpc.tmpl" | jq . > $d4aws_file
}

function modify_d4aws {
  d4aws_json=$(cat $d4aws_file)

  # Add NodeNamePrefix parameter
  d4aws_json=$(echo $d4aws_json | jq '.Parameters.NodeNamePrefix = { "Default": "swarm", "Description": "Manager and worker nodes name prefix", "Type": "String" }')
  d4aws_json=$(echo $d4aws_json | jq '(.Metadata."AWS::CloudFormation::Interface".ParameterGroups[] | select(.Label.default == "Swarm Properties") | .Parameters) += [ "NodeNamePrefix" ]')
  d4aws_json=$(echo $d4aws_json | jq '.Metadata."AWS::CloudFormation::Interface".ParameterLabels.NodeNamePrefix = { "default": "Name prefix for managers and workers" }')
  d4aws_json=$(echo $d4aws_json | jq '(.Resources.ManagerAsg.Properties.Tags[] | select(.Key == "Name") | .Value."Fn::Join"[1]) = [ { "Ref": "NodeNamePrefix" }, "manager" ]')
  d4aws_json=$(echo $d4aws_json | jq '(.Resources.NodeAsg.Properties.Tags[] | select(.Key == "Name") | .Value."Fn::Join"[1]) = [ { "Ref": "NodeNamePrefix" }, "worker" ]')

  # Add EnablePublicAccess parameter
  manager_lc=$(grep -o -m 1 -e 'ManagerLaunchConfig[^"]*' $d4aws_file)
  worker_lc=$(grep -o -m 1 -e 'NodeLaunchConfig[^"]*' $d4aws_file)
  d4aws_json=$(echo $d4aws_json | jq '.Parameters.EnablePublicAccess = { "AllowedValues": ["no", "yes"], "Default": "no", "Description": "Enable internet access to nodes", "Type": "String" }')
  d4aws_json=$(echo $d4aws_json | jq '(.Metadata."AWS::CloudFormation::Interface".ParameterGroups[] | select(.Label.default == "Swarm Properties") | .Parameters) += [ "EnablePublicAccess" ]')
  d4aws_json=$(echo $d4aws_json | jq '.Metadata."AWS::CloudFormation::Interface".ParameterLabels.EnablePublicAccess = { "default": "Enable public internet access?" }')
  d4aws_json=$(echo $d4aws_json | jq '.Conditions.AssociatePublicIp = { "Fn::Equals": [{ "Ref": "EnablePublicAccess" }, "yes"] }')
  d4aws_json=$(echo $d4aws_json | jq '.Resources.'"$manager_lc"'.Properties.AssociatePublicIpAddress = { "Fn::If" : ["AssociatePublicIp", "true", "false"] }')
  d4aws_json=$(echo $d4aws_json | jq '.Resources.'"$worker_lc"'.Properties.AssociatePublicIpAddress = { "Fn::If" : ["AssociatePublicIp", "true", "false"] }')

  # Validate the new JSON and write back the file
  echo $d4aws_json | jq . > $d4aws_file

  printf "${green}Docker CE for AWS is updated.${nocolor}\n"
}


process_args "$@"
download_d4aws "$channel"
modify_d4aws
