resource "aws_s3_bucket" "unsafe" {
  bucket = "my-public-demo-bucket9"
  acl    = "public-read"
}
