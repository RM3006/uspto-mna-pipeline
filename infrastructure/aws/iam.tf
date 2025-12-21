resource "aws_iam_role" "snowflake_reader" {
  name = "uspto_snowflake_reader_role"

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
            "sts:ExternalId" = "JM43233_SFCRole=4_JwyEb3E07JZECGNhDfd27SIq+iQ=" 
          }
        }
      }
    ]
  })
}