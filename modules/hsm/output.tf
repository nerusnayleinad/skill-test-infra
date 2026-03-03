output "cloudhsm_security_group_id" {
  description = "The ID of the security group associated with the CloudHSM cluster."
  value       = aws_cloudhsm_v2_cluster.task1_hsm_cluster.security_group_id
}