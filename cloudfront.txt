

resource "aws_s3_bucket" "s3-test-tf" {
  bucket = "s3-test-tf-july-20"
}

resource "aws_s3_bucket_policy" "s3-bucket-policy" {
  bucket = aws_s3_bucket.s3-test-tf.id
  policy = <<POLICY
{
    "Version": "2008-10-17",
    "Id": "PolicyForCloudFrontPrivateContent",
    "Statement": [
        {
            "Sid": "1",
            "Effect": "Allow",
            "Principal": {
                "AWS": "${aws_cloudfront_origin_access_identity.cloudfront-oai.iam_arn}"
            },
            "Action": "s3:GetObject",
            "Resource": "${aws_s3_bucket.s3-test-tf.arn}/*"
        }
    ]
}
POLICY
}

resource "aws_s3_bucket_ownership_controls" "s3-ownwership-control" {
  bucket = aws_s3_bucket.s3-test-tf.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "s3-make-public-access" {
  bucket = aws_s3_bucket.s3-test-tf.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}


resource "aws_s3_bucket_acl" "s3-acl" {
  depends_on = [
    aws_s3_bucket_ownership_controls.s3-ownwership-control
  ]

  bucket = aws_s3_bucket.s3-test-tf.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "versioning-s3-bucket" {
  bucket = aws_s3_bucket.s3-test-tf.id
  versioning_configuration {
    status = "Enabled"
  }
}


resource "aws_s3_bucket_website_configuration" "s3-test-tf-static-hosting" {
  bucket = aws_s3_bucket.s3-test-tf.id

  index_document {
    suffix = "index.html"
  }

}

resource "aws_s3_bucket_cors_configuration" "s3-test-rf-cors-configuration" {
  bucket = aws_s3_bucket.s3-test-tf.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["HEAD", "DELETE", "PUT", "POST", "GET"]
    allowed_origins = ["*"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}


data "aws_cloudfront_origin_request_policy" "this" {
  name = "Managed-CORS-S3Origin"
}

data "aws_cloudfront_cache_policy" "this" {
  name = "Managed-CachingOptimized"
}



resource "aws_cloudfront_origin_access_identity" "cloudfront-oai" {
  comment = "oai comment"
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = aws_s3_bucket.s3-test-tf.bucket_regional_domain_name
    origin_id   = aws_s3_bucket.s3-test-tf.id
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.cloudfront-oai.cloudfront_access_identity_path
    }
  }
   enabled             = true
   comment             = "tf-cloudfront-july-20"
   default_root_object = "index.html"
   http_version        = "http2"
   
  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = aws_s3_bucket.s3-test-tf.id


    origin_request_policy_id = data.aws_cloudfront_origin_request_policy.this.id
    cache_policy_id          = data.aws_cloudfront_cache_policy.this.id
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }
    price_class = "PriceClass_200"
    restrictions {
    geo_restriction {
      restriction_type = "none"
      locations        = []
    }
  }
custom_error_response {
       error_code = 404
       response_code      = 200
       response_page_path = "/index.html" 
}

custom_error_response {
       error_code = 403
       response_code      = 200
       response_page_path = "/index.html" 
}



  tags = {
    Environment = "test-distribution"
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }


}










