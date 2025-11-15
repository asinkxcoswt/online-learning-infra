# Prepare Cloudfront Signing Key

1. Private key (2048-bit RSA) `openssl genrsa -out cloudfront-private-key.pem 2048`
2. Public key in PEM format `openssl rsa -in cloudfront-private-key.pem -pubout -out cloudfront-public-key.pem`
3. Login to AWS Console -> SSM Parameter, and create a secured parameter `/online-learning/cf-signing-key/public` and `/online-learning/cf-signing-key/private` with the content of the created key pair

# Getting Started

1. Installing AWS CLI and configure the credentials to your target account
2. Checkout the source code, main branch
3. Open `main.tf` and edit the state bucket (`online-learning-tf-state-bucket`) to other name, and manually create that bucket in your AWS account
4. Run `terraform init`
5. Run `terraform plan`
6. Run `terraform apply`

