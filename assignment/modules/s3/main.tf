resource "aws_s3_bucket" "main" {
  bucket = var.bucket_name

lifecycle {
    ignore_changes = all
    
  }
}
