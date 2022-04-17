# AWS Jenkins Server 
Provision an EC2 ubuntu server in AWS running Jenkins. 
This assumes you already have both Terraform and AWS CLI installed and configured

## In Progress
Need to add ebs snapshots and restore from those if avaliable 
add and configure lets encrypt to allow https connections 

## Step 0: Create `.tfvars` file
```
mkdir vars
cd vars
nano secrets.tfvars
copy and paste the snippet below.

aws_region = "us-east-1 OR ANY ORTHER REGION"
vpc_id = "YOUR VPC ID"
cidr_block = "YOUR IP ADDRESS EX 255.255.255.255/32"
key_name = "EXISTING RSA KEY IN AWS"

Save 
The above file will not be committed to your git repostiory thanks to the .gitnore file 
but it is still good security practice to delete this file if you arent working with it.
```

## Step 1: Initialize Repo
```
terraform init
```

## Step 2: Plan Resources
```
terraform plan -var-file="vars/secrets.tfvars"
```

## Step 3: Apply Resources
```
terraform apply -var-file="vars/secrets.tfvars"
```
