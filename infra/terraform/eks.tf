# EKS Cluster - Production Ready Setup
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.cluster_name
  cluster_version = var.kubernetes_version

  vpc_id                   = aws_vpc.main.id
  subnet_ids               = [aws_subnet.main.id, aws_subnet.secondary.id]
  control_plane_subnet_ids = [aws_subnet.main.id, aws_subnet.secondary.id]

  # Cluster endpoint configuration
  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true
  
  # Security configurations
  cluster_endpoint_public_access_cidrs = ["0.0.0.0/0"]
  
  # Encryption at rest - using AWS managed keys for now
  # cluster_encryption_config = {
  #   provider_key_arn = aws_kms_key.eks.arn
  #   resources        = ["secrets"]
  # }

  # EKS Managed Node Groups - Optimized for multiple environments
  eks_managed_node_groups = {
    # General purpose nodes for most workloads
    general = {
      min_size       = var.min_capacity
      max_size       = var.max_capacity
      desired_size   = var.desired_capacity
      instance_types = [var.instance_type]
      capacity_type  = "ON_DEMAND"
      
      # Launch template configuration
      launch_template_name            = "fintrax-eks-general-template"
      launch_template_use_name_prefix = true
      launch_template_version         = "$Latest"
      
      # EBS optimization
      ebs_optimized = true
      
      # Block device mappings
      block_device_mappings = {
        xvda = {
          device_name = "/dev/xvda"
          ebs = {
            volume_size           = 50
            volume_type           = "gp3"
            iops                  = 3000
            throughput            = 150
            # encrypted             = true
            # kms_key_id            = aws_kms_key.eks.arn
            delete_on_termination = true
          }
        }
      }
      
      # Metadata options
      metadata_options = {
        http_endpoint               = "enabled"
        http_tokens                 = "required"
        http_put_response_hop_limit = 2
        instance_metadata_tags      = "disabled"
      }
      
      # Labels for environment scheduling
      labels = {
        NodeGroup   = "general"
        WorkloadType = "application"
      }
      
      # Taints - None for general nodes
      taints = []
      
      # Tags
      tags = {
        Environment = "multi-env"
        Terraform   = "true"
        Project     = "fintrax"
        NodeGroup   = "general"
        Purpose     = "application-workloads"
      }
    }
    
    # Monitoring specific nodes (optional for dedicated monitoring)
    monitoring = {
      min_size       = 1
      max_size       = 2
      desired_size   = 1
      instance_types = ["t3.medium"]
      capacity_type  = "SPOT"  # Cost optimization for monitoring
      
      # Launch template configuration
      launch_template_name            = "fintrax-eks-monitoring-template"
      launch_template_use_name_prefix = true
      launch_template_version         = "$Latest"
      
      # EBS optimization
      ebs_optimized = true
      
      # Block device mappings
      block_device_mappings = {
        xvda = {
          device_name = "/dev/xvda"
          ebs = {
            volume_size           = 30  # Smaller for monitoring
            volume_type           = "gp3"
            iops                  = 3000
            throughput            = 150
            # encrypted             = true
            # kms_key_id            = aws_kms_key.eks.arn
            delete_on_termination = true
          }
        }
      }
      
      # Metadata options
      metadata_options = {
        http_endpoint               = "enabled"
        http_tokens                 = "required"
        http_put_response_hop_limit = 2
        instance_metadata_tags      = "disabled"
      }
      
      # Labels for monitoring workloads
      labels = {
        NodeGroup   = "monitoring"
        WorkloadType = "monitoring"
      }
      
      # Taints for dedicated monitoring nodes
      taints = [
        {
          key    = "workload-type"
          value  = "monitoring"
          effect = "NO_SCHEDULE"
        }
      ]
      
      # Tags
      tags = {
        Environment = "monitoring"
        Terraform   = "true"
        Project     = "fintrax"
        NodeGroup   = "monitoring"
        Purpose     = "monitoring-workloads"
      }
    }
  }

  # Cluster access entry
  enable_cluster_creator_admin_permissions = true
  
  # EKS Addons
  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
      configuration_values = jsonencode({
        env = {
          ENABLE_PREFIX_DELEGATION = "true"
          WARM_PREFIX_TARGET       = "1"
        }
      })
    }
    aws-ebs-csi-driver = {
      most_recent = true
      service_account_role_arn = module.irsa-ebs-csi.iam_role_arn
    }
  }

  # OIDC Identity provider
  cluster_identity_providers = {
    sts = {
      client_id = "sts.amazonaws.com"
    }
  }

  # CloudWatch logging
  cluster_enabled_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  tags = {
    Environment = "development"
    Terraform   = "true"
    Project     = "fintrax"
  }
}

# KMS key for EKS cluster encryption - disabled for now
# resource "aws_kms_key" "eks" {
#   description             = "EKS Secret Encryption Key"
#   deletion_window_in_days = 7
#   enable_key_rotation     = true

#   tags = {
#     Name = "fintrax-eks-encryption-key"
#   }
# }

# resource "aws_kms_alias" "eks" {
#   name          = "alias/fintrax-eks-encryption-key"
#   target_key_id = aws_kms_key.eks.key_id
# }

# IRSA for EBS CSI Driver
module "irsa-ebs-csi" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "~> 5.0"

  create_role                   = true
  role_name                     = "fintrax-ebs-csi-irsa"
  provider_url                  = module.eks.cluster_oidc_issuer_url
  role_policy_arns              = ["arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"]
  oidc_fully_qualified_subjects = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]

  tags = {
    Name = "fintrax-ebs-csi-irsa"
  }
}
