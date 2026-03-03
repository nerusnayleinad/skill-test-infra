# HSM
resource "aws_cloudhsm_v2_cluster" "task1_hsm_cluster" {
  hsm_type   = "hsm2m.medium"
  mode       = var.hsm_mode
  subnet_ids = var.hsm_subnet_ids

  tags = {
    Name = "task1-hsm-cluster-${var.name_suffix}"
  }
}

resource "aws_cloudhsm_v2_hsm" "task1_hsm" {
  subnet_id  = var.hsm_subnet_ids[0]
  cluster_id = aws_cloudhsm_v2_cluster.task1_hsm_cluster.id
}