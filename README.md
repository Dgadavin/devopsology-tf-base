# Terraform

Download [terraform](https://www.terraform.io/downloads.html)

```bash
unzip terraform.zip
cp terraform /usr/local/bin/terraform
chmod u+x /usr/local/bin/terraform
terraform version
```

## AWS authentication

Please use your crenetials.csv file that you download when create IAM user or generate
new one.
Create file `~/aws_creds.txt` with such content:

```bash
export AWS_ACCESS_KEY_ID=""
export AWS_SECRET_ACCESS_KEY=""
```

Before start terraform commands please do:

```bash
source ~/aws_creds.txt
```

More info how to authenticate in AWS you can find [here](https://www.terraform.io/docs/providers/aws/index.html#authentication)

## Install awscli

```bash
easy_install pip
pip install awscli
aws configure
```

## Configure and run first project

Before start we need to set ENV variables
```bash
cd simple-ec2-creation
export TF_VAR_vpc_id=$(aws ec2 describe-vpcs --filters "Name=isDefault, Values=true" --query 'Vpcs[*].{id:VpcId}' --output text --region us-east-1)
export TF_VAR_subnet_id=$(aws ec2 describe-subnets --query 'Subnets[0].{id:SubnetId}' --output text --region us-east-1)
export TF_VAR_env=dev
```

```bash
terraform init
terraform plan
terraform apply
```

### Create S3 bucket for storing states

```bash
aws s3api create-bucket --bucket devopsology-tf-<YOUR_NAME> --region us-east-1
```

### Config remote state
Please open text editor and in config directory rename all `@@bucket@@` placeholders with name of your bucket for states

### Init terraform with remote state

```bash
terraform init -backend-config=config/${TF_VAR_env}-state.conf
terraform plan
terraform apply
```

### Use tfvars to deploy different environment

```bash
terraform plan -var-file=environment/${TF_VAR_env}.tfvars
terraform apply -var-file=environment/${TF_VAR_env}.tfvars
terraform destroy -var-file=environment/${TF_VAR_env}.tfvars
```

# Terraform modules

## Simple ec2 creation with module from terraform registry

```bash
cd ec2_with_module
terraform plan
terraform apply
```

## Create base AWS setup with VPC with custom module

```bash
cd base_aws_setup
export TF_VAR_env=prod
terraform init -backend-config=config/${TF_VAR_env}-state.conf
terraform apply -var-file=environment/${TF_VAR_env}.tfvars
terraform destroy -var-file=environment/${TF_VAR_env}.tfvars
```

## Using secrets with AWS parameter store

If you need to store secrets and lookup it from parameter store you can do next.

Add secret parameter to the parameter store with AWS CLI:

```bash
aws ssm put-parameter --name "SECRET_NAME" --type "SecureString" --overwrite --value "YOUR_SECRET" --region <YOUR_REGION>
```

In terraform you can use such parameter:

```hcl
data "aws_ssm_parameter" "example" {
  name = "SECRET_NAME"
}
```
This will lookup your secret from AWS Parameter store. To use it in you code do this:

```hcl
data.aws_ssm_parameter.example.value
```