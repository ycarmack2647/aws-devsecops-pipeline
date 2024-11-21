resource "random_id" "this" {
  byte_length = 8
}

resource "aws_s3_bucket" "this" {
  bucket = "${var.bucket_prefix}-${random_id.this.hex}"

  force_destroy = true

  tags = {
    Name = var.bucket_name
  }
}
