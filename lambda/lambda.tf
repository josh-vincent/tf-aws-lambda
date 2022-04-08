resource "aws_iam_role" "iam_role_for_lambda" {
  name = "iam_role_for_lambda"
  assume_role_policy = file("${path.module}/files/policy/lambda_assume_role_policy.json")
}

resource "aws_iam_policy" "lambda_logging" {
  name        = "lambda_logging"
  path        = "/"
  description = "IAM policy for logging from a lambda"
  policy = file("${path.module}/files/policy/lambda_logging_policy.json")
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.iam_role_for_lambda.name
  policy_arn = aws_iam_policy.lambda_logging.arn
}


locals {
  function_name = "hello-world-lambda"
  handler = "index.handler"
  // The .zip file we will create and upload to AWS later on
  zip_file = "hello-world-lambda.zip"
}

data "archive_file" "lambda_zip" {
  excludes = [
    ".env",
    ".terraform",
    ".terraform.lock.hcl",
    "docker-compose.yml",
    "main.tf",
    "terraform.tfstate",
    "terraform.tfstate.backup",
    local.zip_file,
  ]
  source_dir = path.module
  type = "zip"
  // Create the .zip file in the same directory as the helloworld.js file
  output_path = "${path.module}/functions/${local.zip_file}"
}

resource "aws_lambda_function" "sample_lambda" {
  filename = local.zip_file
  function_name = "lambda_terraform_function_name"
  role          = aws_iam_role.iam_role_for_lambda.arn
  handler       = "index.handler"
  // Upload the .zip file Terraform created to AWS
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  runtime = "nodejs12.x"

  environment {
  }
}

