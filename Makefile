channel ?= edge
access_key := $(shell cat terraform/terraform.tfvars | grep access_key | grep -oe '".*"')
secret_key := $(shell cat terraform/terraform.tfvars | grep secret_key | grep -oe '".*"')
region := $(shell cat terraform/terraform.tfvars | grep region | grep -oe '".*"')
environment := $(shell cat terraform/terraform.tfvars | grep environment | grep -oe '".*"')


clean:
	@ rm -f terraform/d4aws-*.pub terraform/d4aws-*.pem ~/.ssh/d4aws-$(environment) && \
	  rm -rf terraform/.terraform terraform/terraform.tfstate terraform/terraform.tfstate.backup

update:
	@ ./update.sh --channel $(channel)

keys:
	@ ssh-keygen -f terraform/d4aws-$(environment) -t rsa -N '' 1> /dev/null && \
	  chmod 400 terraform/d4aws-$(environment) && \
	  cp terraform/d4aws-$(environment) ~/.ssh/d4aws-$(environment) && \
	  mv terraform/d4aws-$(environment) terraform/d4aws-$(environment).pem

init:
	@ cd terraform && \
	  terraform init

plan:
	@ cd terraform && \
	  terraform plan

apply:
	@ cd terraform && \
	  terraform apply

destroy:
	@ cd terraform && \
	  terraform destroy

manager-ssh:
	@ ./connect.sh \
	  --access-key $(access_key) \
	  --secret-key $(secret_key) \
	  --region $(region) \
	  --environment $(environment) \
	  --node manager \
	  --action ssh

manager-tunnel:
	@ ./connect.sh \
	  --access-key $(access_key) \
	  --secret-key $(secret_key) \
	  --region $(region) \
	  --environment $(environment) \
	  --node manager \
	  --action tunnel

worker-ssh:
	@ ./connect.sh \
	  --access-key $(access_key) \
	  --secret-key $(secret_key) \
	  --region $(region) \
	  --environment $(environment) \
	  --node worker \
	  --action ssh

worker-tunnel:
	@ ./connect.sh \
	  --access-key $(access_key) \
	  --secret-key $(secret_key) \
	  --region $(region) \
	  --environment $(environment) \
	  --node worker \
	  --action tunnel


.PHONY: clean
.PHONY: update keys
.PHONY: init plan apply destroy
.PHONY: manager-ssh manager-tunnel worker-ssh worker-tunnel
