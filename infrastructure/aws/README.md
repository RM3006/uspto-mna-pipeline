# AWS Infrastructure (Terraform)

This directory contains the Terraform configuration files required to provision the Data Lake layer of the pipeline.

## Resources Provisioned

### Storage
* **S3 Bucket:** A private, versioned bucket (`uspto-data-lake-{random_id}`) used to store raw XML files downloaded from the USPTO.
* **Public Access Block:** Enforces strict security by blocking all public access to the bucket.

### Identity & Access Management (IAM)
* **Python Uploader User:** An IAM user with restricted permissions (`s3:PutObject`) used by the ingestion scripts to upload raw data.
* **Snowflake Reader Role:** An IAM role designed to be assumed by the Snowflake storage integration. It grants read-only access (`s3:GetObject`, `s3:ListBucket`) to the Data Lake.
* **Trust Policy:** A specific policy allowing the external Snowflake account to assume the Reader Role.

## Key Files
* `main.tf`: Defines the S3 bucket, the uploader user, and generates the local `.env` file with output credentials.
* `iam.tf`: Defines the trust relationship between AWS and Snowflake.
* `provider.tf` (implicit): Configures the AWS provider and region (`us-east-1`).

## Outputs
Upon successful application, Terraform outputs the **Bucket Name** and **Role ARN** required to configure the Snowflake Storage Integration (at root of the project .env.generated)