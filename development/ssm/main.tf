locals { 
  env = "dev"
}

variable "hot_wallet_value" {
  type = string

}

resource "aws_secretsmanager_secret" "hot_wallet" {
  name = "hot-wallet"
}

resource "aws_secretsmanager_secret_version" "hot_wallet" {
  secret_id = aws_secretsmanager_secret.hot_wallet
  secret_string = var.hot_wallet_value
}

data "aws_kms_key" "kms" {
  key_id = "alias/main-kms-key"
}
