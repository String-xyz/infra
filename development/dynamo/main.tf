locals { 
  env = "dev"
}

resource "aws_dynamodb_table" "table" {
  name = "string-ddb"
  billing_mode = "PAY_PER_REQUEST"
  
  attribute {
    name = "pk"
    type = "S"
  }
  
  attribute {
    name = "sk"
    type = "S"
  }

  hash_key = "pk"
  range_key = "sk"

  server_side_encryption {
    enabled = true
    kms_key_arn = data.aws_kms_key.kms.arn
  }

  tags = {
    Name = "string-ddb"
    Environment = local.env
  }
}

resource "aws_ssm_parameter" "table_arn" {
  name = aws_dynamodb_table.table.name
  value = aws_dynamodb_table.table.arn
  type = "String"
}

resource "aws_dynamodb_table" "demo" {
  name = "demo-ddb"
  billing_mode = "PAY_PER_REQUEST"
  
  attribute {
    name = "pk"
    type = "S"
  }

  attribute {
    name = "sk"
    type = "S"
  }
  
  hash_key = "pk"
  range_key = "sk"

  server_side_encryption {
    enabled = true
    kms_key_arn = data.aws_kms_key.kms.arn
  }
}

resource "aws_ssm_parameter" "demo_arn" {
  name = aws_dynamodb_table.demo.name
  value = aws_dynamodb_table.demo.arn
  type = "String"
}

data "aws_kms_key" "kms" {
  key_id = "alias/main-kms-key"
}

