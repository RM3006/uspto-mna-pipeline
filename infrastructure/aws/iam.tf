# 1. The Snowflake Reader Role (Identity + Trust Policy)
resource "aws_iam_role" "snowflake_reader" {
  name = "uspto_snowflake_reader_role"

  # TRUST POLICY: This connects Snowflake to AWS
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          # Get STORAGE_AWS_IAM_USER_ARN value from the storage integration in snowflake
          AWS = "arn:aws:iam::260512157176:user/e8z81000-s" 
        }
        Action = "sts:AssumeRole"
        Condition = {
          StringEquals = {
            # Get STORAGE_AWS_EXTERNAL_ID value from the storage integration in snowflake
            "sts:ExternalId" = "JM43233_SFCRole=4_tWa/XUiHv3UXmxSkBpnSe3PeupY=" 
          }
        }
      }
    ]
  })
}

# 2. The Permissions Policy (What Snowflake can DO)
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

# 3. Attach Permissions to Role
resource "aws_iam_role_policy_attachment" "attach_read_snowflake" {
  role       = aws_iam_role.snowflake_reader.name
  policy_arn = aws_iam_policy.snowflake_read_policy.arn
}

# 4. Output the ARN (Required for Snowflake Integration)
output "snowflake_role_arn" {
  value = aws_iam_role.snowflake_reader.arn
}