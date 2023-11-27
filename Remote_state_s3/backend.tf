# comment this block while initializing the remote backend then uncomment and init with -migrate-state
# terraform {

#   backend "s3" {
#     region         = "your-region-name"
#     bucket         = "your-s3-bucket-name"
#     key            = "global/terraform.tfstate"
#     dynamodb_table = "your-dynamodb-name"
#     encrypt        = true
#   }
# }