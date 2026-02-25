############################
# STEP FUNCTION STATE MACHINE
############################

resource "aws_sfn_state_machine" "review_state_machine" {
  name     = "tf-review-state-machine"
  role_arn = aws_iam_role.step_role.arn
  definition = jsonencode({
    Comment = "Review workflow for Terraform PRs"
    StartAt = "AgentSecurity"
    States = {
      AgentSecurity = {
        Type = "Task"
        Resource = "arn:aws:lambda:${var.aws_region}:${var.aws_account_id}:function:agent_security"
        Next = "AgentCost"
      }
      AgentCost = {
        Type = "Task"
        Resource = "arn:aws:lambda:${var.aws_region}:${var.aws_account_id}:function:agent_cost"
        Next = "AgentIAM"
      }
      AgentIAM = {
        Type = "Task"
        Resource = "arn:aws:lambda:${var.aws_region}:${var.aws_account_id}:function:agent_iam"
        Next = "AgentGovernance"
      }
      AgentGovernance = {
        Type = "Task"
        Resource = "arn:aws:lambda:${var.aws_region}:${var.aws_account_id}:function:agent_governance"
        End = true
      }
    }
  })
}
provider "aws" {
  region = "us-east-1"
}

resource "random_id" "suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "scan_bucket" {
  bucket = "tf-scan-results-${random_id.suffix.hex}"
}

############################
# IAM ROLES
############################

resource "aws_iam_role" "lambda_role" {
  name = "tf-review-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "basic" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "s3" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

############################
# STEP FUNCTION ROLE
############################

resource "aws_iam_role" "step_role" {
  name = "tf-review-step-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "states.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "step_policy" {
  role = aws_iam_role.step_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = "lambda:InvokeFunction"
      Resource = "*"
    }]
  })
}