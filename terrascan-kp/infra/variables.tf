variable "aws_region" {
  description = "AWS region for Lambda and Step Function"
  type        = string
  default     = "us-east-1"
}

variable "aws_account_id" {
  description = "AWS account ID for Lambda ARNs"
  type        = string
}
variable "openai_key" {}
variable "github_token" {}
variable "repo_owner" {}
variable "repo_name" {}

variable "kp_github_token" {
  description = "GitHub token for authentication"
  type        = string
}