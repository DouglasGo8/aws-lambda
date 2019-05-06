provider "aws" {
  region = "us-east-1"
}

resource "aws_lambda_function" "authorizer" {
  filename      = "../../../../target/vertx-aws-lambda-app-1.0-SNAPSHOT.jar"
  function_name = "vertx_authorizer_lambda"
  role          = "${aws_iam_role.iam_for_lambda}"
  handler       = "com.pagseguro.lambda.vertx.core.authorizer.service.Handler"
  runtime       = "java8"
}

resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

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
