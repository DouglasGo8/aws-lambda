#variable "app_version" { # sera usado para versionamento 
#}


provider "aws" {
  region = "${var.aws_region}"
}

resource "aws_lambda_function" "terraform" { #terraform nao representa key word poderia ser terraform-hello-world
  function_name = "terraform-hello-world-function"

  s3_bucket = "terraform-hello-world-bucket"
  s3_key    = "index.zip" # "v${var.app_version}/index.zip" terraform apply -var="app.version=num_of_version"

  handler = "index.handler"

  runtime = "nodejs8.10"

  role = "${aws_iam_role.lambda_exec.arn}"
}

resource "aws_iam_role" "lambda_exec" {
  name = "terraform-hello-world"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
    EOF
}

resource "aws_api_gateway_resource" "proxy" {
    rest_api_id = "${aws_api_gateway_rest_api.terraform.id}"
    parent_id = "${aws_api_gateway_rest_api.terraform.root_resource_id}"
    path_part = "hello" #  activates proxy behavior, which means that this resource will match any request path
}

resource "aws_api_gateway_method" "proxy" {

    rest_api_id =  "${aws_api_gateway_rest_api.terraform.id}"
    resource_id = "${aws_api_gateway_resource.proxy.id}"
    http_method = "GET" # allows any request method to be used.
    authorization = "NONE"
  
}

resource "aws_api_gateway_integration" "lambda" {
    rest_api_id = "${aws_api_gateway_rest_api.terraform.id}"
    resource_id = "${aws_api_gateway_method.proxy.resource_id}"
    http_method = "${aws_api_gateway_method.proxy.http_method}"
  
    integration_http_method = "POST"
    type = "AWS_PROXY"
    uri = "${aws_lambda_function.terraform.invoke_arn}"
}

resource "aws_api_gateway_method" "proxy_root" {
    rest_api_id = "${aws_api_gateway_rest_api.terraform.id}"
    resource_id = "${aws_api_gateway_rest_api.terraform.root_resource_id}"
    http_method = "GET"
    authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_root" {
    rest_api_id = "${aws_api_gateway_rest_api.terraform.id}"
    resource_id = "${aws_api_gateway_method.proxy_root.resource_id}"
    http_method = "${aws_api_gateway_method.proxy_root.http_method}"

    integration_http_method = "POST"
    type = "AWS_PROXY"
    uri = "${aws_lambda_function.terraform.invoke_arn}"
}

resource "aws_api_gateway_deployment" "terraform" {
    depends_on = [
        "aws_api_gateway_integration.lambda",
        "aws_api_gateway_integration.lambda_root",
    ]  

    rest_api_id = "${aws_api_gateway_rest_api.terraform.id}"
    stage_name = "test"
}


resource "aws_lambda_permission" "apigtw" {

    statement_id = "AllowAPIGatewayInvoke"
    action = "lambda:InvokeFunction"
    function_name = "${aws_lambda_function.terraform.arn}"
    principal = "apigateway.amazonaws.com"

    # The /*/* portion grants access from any method on any resource within the API Gateway "REST API".  
    source_arn = "${aws_api_gateway_deployment.terraform.execution_arn}/*/*"  
                                                                             
}
