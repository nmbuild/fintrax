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
  
  # Encryption at rest
  cluster_encryption_config = {
    provider_key_arn = aws_kms_key.eks.arn
    resources        = ["secrets"]
  }

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
      
      # Note: remote_access is not compatible with launch_template
      
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
            encrypted             = false
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
      
      # Note: remote_access is not compatible with launch_template
      
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
            encrypted             = false
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

# KMS key for EKS cluster encryption
resource "aws_kms_key" "eks" {
  description             = "EKS Secret Encryption Key"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = {
    Name = "fintrax-eks-encryption-key"
  }
}

resource "aws_kms_alias" "eks" {
  name          = "alias/fintrax-eks-encryption-key"
  target_key_id = aws_kms_key.eks.key_id
}

# Security group for remote access to EKS nodes
resource "aws_security_group" "eks_remote_access" {
  name_prefix = "fintrax-eks-remote-access"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = ["10.0.0.0/16"] # Only allow SSH from within VPC
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "fintrax-eks-remote-access"
  }
}

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

# Create SSH key for node access
resource "aws_key_pair" "eks_key" {
  key_name   = "fintrax-eks-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC01WtFzGcdqcRtTQV16mXKk0Jnbn0kXFDmxoSfBeVqZXZyO65ZImSlKe9NybkSRC64bmBWL6Wo9zE+s2w74KkdxqBh6d5CKrop2P0HxmA15p17anyGRQwbPAuHTfjQMQW+7jF8WOnzIlzeZ4SGL+6Y2xLmitLmKWydArO1lbvWp1lzdINYL6nRew5BYh1xTc03YaAV8Kb2QVxjdIgRW5gRD2Pzr+0/CwUmuJndfJDknla7+DgpRM3tuhSUkoAIoPg/cFHrBtGJQWAyNxL2/lsOmO9e3WD+G6fkHWsZf89SP8k652li2qJimC7/OLDpLMyxp+46iAfRfKVNR+3PRlAHAszeXuUrckOvMA2OkrtC+o+y/dPBVqDUAZApvawD67Um0Au3PHABjIBVAP+vX+IrJ3I2g6BxlftsMUNWwPwMtqQ4RJxZsZXOc05Iy/k8shv+i+kWVR3R+Y7AH3NtuWjj6g4jUpgeAD8AY1C2vVZwDpmlzEp5+M8c2/G+VYgFE8PVo+ZLQaBNMkHvxlOS5ehj62AL4n6JWVapfnmx04wo5sAtuUec8vVmJke2HagEW6kCVNp9g5YtBW+gmw56WtHJuK+PKI+cX+idMkR/vma9g92iXf75Rn6wJYWdUBukLlr8vlow0qBp50WiNCUXYQHpzW0jnn4e1fdHfGSL82AgOQ== fintrax-eks-nodes"
  
  tags = {
    Name = "fintrax-eks-key"
  }
}
