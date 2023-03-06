resource "aws_s3_bucket" "b" {
  bucket = "gha-arc-test-bucket"

  tags = {
    Name        = "GHA ARC Runner test"
    Environment = "right"
  }
}

resource "aws_s3_bucket_acl" "example" {
  bucket = aws_s3_bucket.b.id
  acl    = "private"
}
