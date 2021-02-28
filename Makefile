# Terrastrap - Bootstrap a S3 & DynamoDB Backend for Terraform
# https://github.com/dozyio/terrastrap
#
# Based on https://github.com/cobusbernard/hashitalks-africa-demo/ minus the workspaces and for bootstrapping only

# From StackOverflow: https://stackoverflow.com/a/20566812
UNAME:= $(shell uname)
ifeq ($(UNAME),Darwin)
	OS_X  := true
	SHELL := /bin/bash
else
	OS_DEB  := true
	SHELL := /bin/bash
endif

TFENV:= $(shell command -v tfenv 2> /dev/null)

#if not using TFENV (https://github.com/tfutils/tfenv), peg Terraform to a specific version
TERRAFORM:= $(shell command -v terraform 2> /dev/null)
TERRAFORM_VERSION:= "0.14.7"

ifeq ($(OS_X),true)
	TERRAFORM_MD5:= $(shell md5 -q `which terraform`)
	TERRAFORM_REQUIRED_MD5:= 952483b865874729a18cc6d00c664b8e
else
	TERRAFORM_MD5:= $(shell md5sum - < `which terraform` | tr -d ' -')
	TERRAFORM_REQUIRED_MD5:= 5f1471a95776c2b1d8b09ac15a15eb00
endif

default:
	@echo ""
	@echo "Creates a boostrapped S3 and DynamoDB backend for Terraform"
	@echo "-----------------------------------------------------------"
	@echo ""
	@echo "The following commands are available:"
	@echo " - bootstrap          : Bootstrap AWS environment for terraform (runs plan and apply)"
	@echo " - bootstrap-plan     : Runs terraform plan to prepare for bootstrap"
	@echo " - bootstrap-apply    : Runs terraform apply to bootstrap the environment"
	@echo " - bootstrap-destroy  : Will delete the entire project's infrastructure (see readme)"
	@echo ""
	@echo "e.g. ENV=dev make bootstrap"
	@echo ""
	@echo ""

check:
ifndef TFENV
	@if [ "${TERRAFORM_MD5}" != "${TERRAFORM_REQUIRED_MD5}" ]; then echo "Please ensure you are running terraform ${TERRAFORM_VERSION}."; exit 1; fi;
endif

bootstrap-plan: check sedreplace
	@echo "Creating terraform plan for a bootstrapped [$(value ENV)] environment"
	$(call check_defined, ENV, Please set the ENV to plan for. Values should be dev stage or prod)
	@cp vars.tf $(value ENV)/
	@cd $(value ENV) && terraform init
	@cd $(value ENV) && terraform fmt
	@echo "Pulling the required modules..."
	@cd $(value ENV) && terraform get
	@cd $(value ENV) && terraform plan  \
		-var-file="../env_vars/$(value ENV).tfvars" \
		-out $(value ENV).plan

bootstrap-apply: check sedreplace
	$(call check_defined, ENV, Please set the ENV to apply. Values should be dev stage or prod)
	@echo "Will be applying the following to [$(value ENV)] environment:"
	@cd $(value ENV) && terraform show $(value ENV).plan
	@cd $(value ENV) && terraform apply $(value ENV).plan
	@cd $(value ENV) && rm $(value ENV).plan

bootstrap-destroy: check sedreplace
	@echo "💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥"
	@echo "Are you really sure you want to completely destroy [$(value ENV)] environment ?"
	@echo "💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥"
	@read -p "Press a button to continue, ctrl+c to cancel"
	@cd $(value ENV) && terraform destroy \
		-var-file="../env_vars/$(value ENV).tfvars"

sedreplace: check
	@sed "s/@TERRAFORM_VERSION/$(value TERRAFORM_VERSION)/g;" \
		terraform-bootstrap.tf > $(value ENV)/terraform.tf

bootstrap: bootstrap-plan bootstrap-apply

.PHONY: default check sedreplace bootstrap-plan bootstrap-apply bootstrap-destroy bootstrap

# Check that given variables are set and all have non-empty values,
# die with an error otherwise.
#
# Params:
#   1. Variable name(s) to test.
#   2. (optional) Error message to print.
check_defined = \
    $(strip $(foreach 1,$1, \
        $(call __check_defined,$1,$(strip $(value 2)))))
__check_defined = \
    $(if $(value $1),, \
      $(error Undefined $1$(if $2, ($2))))

