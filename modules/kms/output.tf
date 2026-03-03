output "kms_s3_key_id" {
  description = "ID of the KMS key"
  value       = aws_kms_external_key.task1_external_key.id
}

output "kms_s3_key_arn" {
  description = "ARN of the KMS key"
  value       = aws_kms_external_key.task1_external_key.arn
}
