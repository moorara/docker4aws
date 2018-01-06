# docker4aws
This is a [Terraform](https://www.terraform.io) project for deploying
[Docker CE for AWS](https://docs.docker.com/docker-for-aws) to an AWS account.

## Quick Start
Create a new file named `terraform.tfvars` in `terraform` directory.
The following variables are required to be set.

```toml
access_key   =  "..."  # Your AWS account Access Key ID
secret_key   =  "..."  # Your AWS account Secret Access Key
region       =  "..."  # The AWS region for deploying
environment  =  "..."  # A name for your deployment
```

The following variables are optional to be set.

```toml
size       =  "..."      # small, medium, or large  (default: small)
whitelist  =  [ "..." ]  # A list of CIDRs to be whitelisted (default: ["0.0.0.0/0"])
```

Then, run the following initialization tasks.

| Command     | Description                                       |
|-------------|---------------------------------------------------|
| make keys   | Generates new ssh keys                            |
| make update | Updates Docker CE for AWS CloudFormation template |

### Deploying

| Command       | Description                                      |
|---------------|--------------------------------------------------|
| make init     | Initializes Terraform project                    |
| make plan     | Dry run of Terraform-managed infrastructure      |
| make apply    | Deploys/Updates Terraform-managed infrastructure |
| make destroy  | Destroys Terraform-managed infrastructure        |

### Connecting

| Command              | Description                       |
|----------------------|-----------------------------------|
| make manager-ssh     | ssh to a manager node             |
| make manager-tunnel  | Tunnel to a manager docker socket |
| make worker-ssh      | ssh to a worker node              |
| make worker-tunnel   | Tunnel to a worker docker socket  |
