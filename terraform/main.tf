module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"
  name    = "eks-vpc"
  cidr    = var.vpc_cidr
  azs     = ["${var.region}a", "${var.region}b"]  
  private_subnets = var.private_subnets_cidr
  public_subnets  = var.public_subnets_cidr
  enable_nat_gateway = true

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"           = "1"
  }
  public_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                    = "1"
  }
}

resource "aws_iam_policy" "eks_policies" {
  for_each = {
    ecr_policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = [
            "ecr:GetAuthorizationToken",
            "ecr:BatchCheckLayerAvailability",
            "ecr:GetDownloadUrlForLayer",
            "ecr:GetRepositoryPolicy",
            "ecr:DescribeRepositories",
            "ecr:ListImages",
            "ecr:BatchGetImage"
          ]
          Resource = "*"
        }
      ]
    })

    alb_policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = [
            "iam:CreateServiceLinkedRole",
            "iam:ListServerCertificates",
            "iam:GetServerCertificate",
            "ec2:Describe*",
            "ec2:AuthorizeSecurityGroupIngress",
            "ec2:RevokeSecurityGroupIngress",
            "ec2:CreateSecurityGroup",
            "elasticloadbalancing:*",
            "acm:ListCertificates",
            "acm:DescribeCertificate",
            "waf-regional:*",
            "wafv2:*",
            "shield:*"
          ]
          Resource = "*"
        }
      ]
    })
  }

  name   = "eks-${each.key}"
  policy = each.value
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"
  cluster_name    = var.cluster_name
  cluster_version = "1.27"
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.private_subnets
  cluster_endpoint_public_access = true
  cluster_endpoint_private_access = true
  
  eks_managed_node_groups = {
    spot = {
      min_size     = 0
      max_size     = 5
      desired_size = 1
      instance_types = ["t3.medium"]
      capacity_type  = "SPOT"

      iam_role_additional_policies = {
        AmazonECR_Policy  = aws_iam_policy.eks_policies["ecr_policy"].arn
        ALBIngress_Policy = aws_iam_policy.eks_policies["alb_policy"].arn
      }
    }
  }
}