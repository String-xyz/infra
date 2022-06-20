locals { 
  env = "dev"
}

variable "hot_wallet_value" {
  type = string
  sensitive = true
}

resource "aws_secretsmanager_secret" "hot_wallet" {
  name = "hot-wallet"
  tags = {
    Environment = local.env
  }
}

resource "aws_secretsmanager_secret_version" "hot_wallet" {
  secret_id = aws_secretsmanager_secret.hot_wallet.id
  secret_string = var.hot_wallet_value
}
