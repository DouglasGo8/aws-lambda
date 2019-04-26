arn:aws:iam::501317491826:role/admin
arn:aws:iam::501317491826:mfa/root-account-mfa-device 


# AWS
 aws s3api create-bucket --bucket=terraform-hello-world-bucket --region=us-east-1
 # CP1 without --v
 aws s3 cp .\index.zip s3://terraform-hello-world-bucket/index.zip
 # CP1 with --v
 aws s3 cp .\index.zip s3://terraform-hello-world/v1.0.0/index.zip

 # Links

 https://learn.hashicorp.com/terraform/aws/lambda-api-gateway
