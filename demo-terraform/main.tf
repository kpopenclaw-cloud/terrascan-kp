resource "aws_s3_bucket" "unsafe" {
  bucket = "my-public-demo-bucket11"
  acl    = "public-read"
}
