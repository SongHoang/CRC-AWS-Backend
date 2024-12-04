
resource "aws_dynamodb_table" "mytable" {
  name           = "DynamoDB-Terraform"
  billing_mode   = "PROVISIONED"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "Website"

  attribute {
    name = "Website"
    type = "S"
  }
  
  tags = {
    Name        = "dynamodb-table-1"
    Environment = "production"
  }
}

# Populate table with starting value of 0 for the CRC website
resource "aws_dynamodb_table_item" "item" {
    table_name = aws_dynamodb_table.mytable.name
    hash_key   = aws_dynamodb_table.mytable.hash_key

    item = <<ITEM
    { 
        "Website": {"S": "CRC"},
        "Visitors": {"N": "0"}
    }
    ITEM

}

