locals {
  environment = var.environment
  name = "${var.environment}"

  eks_cluster_name = "${local.name}-${var.cluster_name}"  
  
  common_tags = {
    
  environment = local.environment
  }
} 