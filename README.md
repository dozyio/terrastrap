# Terrastrap - Bootstrap a S3 and DynamoDB backend for Terraform

Supports multiple AWS accounts for isolation.

## Bootstrap environments

Copy the example tfvar files and edit as appropriate.

```
cp env_vars/dev.tfvars.example env_vars/dev.tfvars
cp env_vars/stage.tfvars.example env_vars/stage.tfvars
cp env_vars/prod.tfvars.example env_vars/prod.tfvars
```

### Create dev backend
```
ENV=dev make bootstrap
```

### Create stage backend
```
ENV=stage make bootstrap
```

### Create prod backend
```
ENV=prod make bootstrap
```

[![asciicast](https://asciinema.org/a/iftOoUzopjVCxVb7cvNDExmlX.svg)](https://asciinema.org/a/iftOoUzopjVCxVb7cvNDExmlX?autoplay=1)

## Using S3 Backend in Terraform
Once the backend has been created, the Terraform outputs will show the S3 bucket
and DyanmoDB table that you can use in your infrastructure.
```
Outputs:

bucket = "dev-dozyio-eu-west-2-tf-state"
dynamodb_table = "dev-dozyio-eu-west-2-tf-lock"
```

These outputs can then be used as follows within your Terraform files
```
terraform {
  required_version = "0.14.7"
  backend "s3" {
    bucket         = "dev-dozyio-eu-west-2-tf-state"
    dynamodb_table = "dev-dozyio-eu-west-2-tf-lock"
    key            = "dev/dozyio/eu-west-2/terraform.tfstate"
    region         = "eu-west-2"
    encrypt        = true
  }
}
```


## Create Additional Environments

e.g. To bootstrap a uat environment, create a uat directory and uat.tfvars file
and edit as appropriate.
```
mkdir uat
cp env_vars/dev.tfvars.example env_vars/uat.tfvars
$EDITOR env_var/uat.tfvars
```

## Destroy Bootstrap Environment

### Destroy dev backend
```
ENV=dev make bootstrap-destroy
```

### Destroy stage backend
```
ENV=stage make bootstrap-destroy
```

### Destroy prod backend
```
ENV=prod make bootstrap-destroy
```

### Destroy error

When destroying a bootstrap, an error will occur as per below.
```
Resource module.bootstrap.aws_s3_bucket.state_bucket has
lifecycle.prevent_destroy set, but the plan calls for this resource to be
destroyed. To avoid this error and continue with the plan, either disable
lifecycle.prevent_destroy or reduce the scope of the plan using the -target
flag.
```

This error is intended as a failsafe incase Terraform tries to delete the
bucket. To delete the bootstrap bucket, change the following
modules/bootstrap/bootstrap_s3_bucket.tf

```
  lifecycle {
    prevent_destroy = true
  }
```

```
  lifecycle {
    #prevent_destroy = true
  }
```

## View Bootstrap Plan

To view the Terraform plan of what would be created when bootstrapping, run the
following.

```
ENV=dev make bootstrap-plan
```

## Changing Terraform Versions

Terrastrap has support for TFENV in as much as it checks for the TFENV binary.

If you're not using TFENV, the Makefile checks your version of Terraform. At
time of writing this is pegged to version 0.14.7. To update, edit the Makefile
and update the TERRAFORM_VERSION and md5 hash.

```
TERRAFORM:= $(shell command -v terraform 2> /dev/null)
TERRAFORM_VERSION:= "0.14.7"

ifeq ($(OS_X),true)
    TERRAFORM_MD5:= $(shell md5 -q `which terraform`)
    TERRAFORM_REQUIRED_MD5:= 952483b865874729a18cc6d00c664b8e
else
    TERRAFORM_MD5:= $(shell md5sum - < `which terraform` | tr -d ' -')
    TERRAFORM_REQUIRED_MD5:= 5f1471a95776c2b1d8b09ac15a15eb00
endif
```

