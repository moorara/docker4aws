[![Build Status][workflow-image]][workflow-url]

# docker4aws

This is a [Terraform](https://www.terraform.io) project for deploying
[Docker CE for AWS](https://docs.docker.com/docker-for-aws) to an AWS account.

<span style="color:red">**IMPORTANT NOTE:**</span>
The [Docker for AWS](https://docs.docker.com/docker-for-aws) project has not been updated for a long time.
It seems this project has been silently shutdown, hence it is NOT recommended to use this project for production purposes.

## Quick Start

Create a new file named `terraform.tfvars` in `terraform` directory.
The following variables are required to be set.

```toml
access_key  = "..."  # Your AWS account Access Key ID
secret_key  = "..."  # Your AWS account Secret Access Key
region      = "..."  # The AWS region for deploying
environment = "..."  # A name for your deployment
```

The following variables are optional to be set.

```toml
size      = "..."      # small, medium, or large  (default: small)
whitelist = [ "..." ]  # A list of CIDRs to be whitelisted (default: ["0.0.0.0/0"])
```

## Tasks

| Command       | Description                                       |
|---------------|---------------------------------------------------|
| `make update` | Updates Docker CE for AWS CloudFormation template |

## Deploying Swarm

| Command         | Description                                      |
|-----------------|--------------------------------------------------|
| `make keys`     | Generates new ssh keys                           |
| `make init`     | Initializes Terraform project                    |
| `make plan`     | Dry run of Terraform-managed infrastructure      |
| `make apply`    | Deploys/Updates Terraform-managed infrastructure |
| `make destroy`  | Destroys Terraform-managed infrastructure        |

## Accessing Swarm

| Command                | Description                       |
|------------------------|-----------------------------------|
| `make manager-ssh`     | ssh to a manager node             |
| `make manager-tunnel`  | Tunnel to a manager docker socket |
| `make worker-ssh`      | ssh to a worker node              |
| `make worker-tunnel`   | Tunnel to a worker docker socket  |


[workflow-url]: https://github.com/moorara/packer/actions
[workflow-image]: https://github.com/moorara/packer/workflows/Main/badge.svg
