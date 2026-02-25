resource "aws_s3_bucket" "unsafe" {
  bucket = "my-public-demo-bucket1"
  acl    = "public-read"
}
