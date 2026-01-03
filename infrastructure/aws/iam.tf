# 1. Create IAM Role for Snowflake to assume (Identity and Trust Policy)
resource "aws_iam_role" "snowflake_reader" {
  name = "uspto_snowflake_reader_role"

  # Configure Trust Policy to connect Snowflake with AWS
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          # Set the ARN from the STORAGE_AWS_IAM_USER_ARN value in Snowflake
          AWS = "arn:aws:iam::260512157176:user/e8z81000-s" 
        }
        Action = "sts:AssumeRole"
        Condition = {
          StringEquals = {
            # Set the External ID from the STORAGE_AWS_EXTERNAL_ID value in Snowflake
            "sts:ExternalId" = "JM43233_SFCRole=4_tWa/XUiHv3UXmxSkBpnSe3PeupY=" 
          }
        }
      }
    ]
  })
}

# 2. Define IAM Policy to grant read access to the S3 bucket
resource "aws_iam_policy" "snowflake_read_policy" {
  name        = "uspto_snowflake_read_access"
  description = "Allows Snowflake to read from the USPTO bucket"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.data_lake.arn,          
          "${aws_s3_bucket.data_lake.arn}/*"
        ]
      }
    ]
  })
}

# 3. Attach the read policy to the Snowflake reader role
resource "aws_iam_role_policy_attachment" "attach_read_snowflake" {
  role       = aws_iam_role.snowflake_reader.name
  policy_arn = aws_iam_policy.snowflake_read_policy.arn
}

# 4. Output the Role ARN for configuration in Snowflake Integration
output "snowflake_role_arn" {
  value = aws_iam_role.snowflake_reader.arn
}