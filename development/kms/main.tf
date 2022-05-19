data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "policy" {
  statement { 
      sid = "Enable IAM User Permission"
      actions = [
          "kms:*"
      ]
      resources = [
          "*"
      ]
      principals { 
          type = "AWS"
          identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
      }
  }

  statement {
    sid = "Allow CloudTrail to encrypt logs"
    actions = [ "kms:GenerateDataKey*" ]
    resources = ["*"]

    condition {
      test = "StringLike"
      variable = "kms:EncryptionContext:aws:cloudtrail:arn"
      values = ["arn:aws:cloudtrail:*:${data.aws_caller_identity.current.account_id}:trail/*"]
    }

    condition {
      test = "StringEquals"
      variable = "aws:SourceArn"
      values = ["arn:aws:cloudtrail:us-west-2:${data.aws_caller_identity.current.account_id}:trail/management-events"]
    }
    
    principals {
      type = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
  }
}

resource "aws_kms_key" "key" {
  description         = "Main KMS for Data Encryption"
  enable_key_rotation = true
  policy = data.aws_iam_policy_document.policy.json
  tags = {
    Name = "main-kms-key"
    Environment = local.env
  }
}

resource "aws_kms_alias" "key_alias" {
  target_key_id = aws_kms_key.key.key_id
  name          = "alias/main-kms-key"
}
