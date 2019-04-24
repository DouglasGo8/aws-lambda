
# The "REST API" is the container for all of the other API Gateway objects we will create.
resource "aws_api_gateway_rest_api" "terraform" {

    name = "terraform_hello_world_api_gtw"
    description = "Terraform Serverless Hello World App"
  
}


output "base_url" {
  value = "${aws_api_gateway_deployment.terraform.invoke_url}"
}
