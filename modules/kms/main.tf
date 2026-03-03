resource "aws_kms_external_key" "task1_external_key" {
  description = "Key wrapper without key material"
  
  tags = {
      Name = "kms-external-key-wrapper-${var.name_suffix}"
  }
}

resource "aws_kms_alias" "task1_external_key" {
  name          = "alias/${var.kms_key_alias}"
  target_key_id = aws_kms_external_key.task1_external_key.id
}