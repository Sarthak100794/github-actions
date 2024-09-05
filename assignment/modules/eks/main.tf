resource "aws_eks_cluster" "main" {
  name = var.cluster_name
  version = var.cluster_version
  role_arn = aws_iam_role.eks_role.arn
  vpc_config {
    subnet_ids = var.subnet_ids
    endpoint_private_access = true
    endpoint_public_access = false
  }
}

resource "aws_iam_role" "eks_role" {
  name = "${var.cluster_name}-eks-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Principal = {
        Service = "eks.amazonaws.com"
      }
      Effect = "Allow"
      Sid = ""
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_policy" {
  role = aws_iam_role.eks_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_eks_node_group" "default" {
  depends_on     = [aws_eks_cluster.main]  
  for_each       = var.node_groups
  cluster_name   = aws_eks_cluster.main.name
  node_group_name = each.value.node_group_name
  node_role_arn  = aws_iam_role.eks_node_group_role.arn
  subnet_ids     = each.value.subnet_ids
  instance_types = each.value.instance_types

  scaling_config {
    desired_size = each.value.desired_capacity
    max_size     = each.value.max_capacity
    min_size     = each.value.min_capacity
  }
}

resource "aws_iam_role" "eks_node_group_role" {
  name = "${var.cluster_name}-node-group-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Effect = "Allow"
      Sid = ""
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  role       = aws_iam_role.eks_node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  role       = aws_iam_role.eks_node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "ec2_container_registry_read_only" {
  role       = aws_iam_role.eks_node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}


resource "aws_eks_addon" "addons" {
  for_each          = { for addon in var.addons : addon.name => addon }
  cluster_name      = aws_eks_cluster.main.id
  addon_name        = each.value.name
  addon_version     = each.value.version
  resolve_conflicts = "OVERWRITE"
}



data "aws_eks_cluster" "default" {
  name = aws_eks_cluster.main.name
}

data "tls_certificate" "default" {
  url = data.aws_eks_cluster.default.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "default" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.default.certificates[0].sha1_fingerprint]
  url             = data.aws_eks_cluster.default.identity[0].oidc[0].issuer
}

resource "aws_iam_role" "default" {
  name = "par-eks-irsa-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Sid    = ""
      Effect = "Allow",
      Principal = {
        Federated = aws_iam_openid_connect_provider.default.arn
      },
      Action = "sts:AssumeRoleWithWebIdentity",
      Condition = {
        StringEquals = {
            "${aws_iam_openid_connect_provider.default.url}:sub" = "system:serviceaccount:default:${var.ksa_name}"
            "${aws_iam_openid_connect_provider.default.url}:aud" = "sts.amazonaws.com"
          }
      }
    }]
  })
}

resource "aws_iam_role_policy" "default" {
  name   = "eks-irsa-policy-par"
  role   = aws_iam_role.default.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = [
        "s3:PutObject"
      ],
      Resource = "*"
    }]
  })
}

 resource "kubernetes_service_account" "par_sa" {
   depends_on     = [aws_eks_cluster.main, aws_eks_node_group.default] 
   metadata {
     name      = var.ksa_name
     namespace = "default"
     annotations = {
       "eks.amazonaws.com/role-arn" = aws_iam_role.default.arn
     }
   }
 }



resource "kubernetes_deployment" "default" {
  for_each = var.deployments
  depends_on = [aws_eks_cluster.main, aws_eks_node_group.default]

  metadata {
    name = each.value.name
    labels = each.value.labels
  }

  spec {
    replicas = each.value.replicas

    selector {
      match_labels = each.value.labels
    }

    template {
      metadata {
        labels = each.value.labels
      }

      spec {
        container {
          image = each.value.image
          name  = each.value.container_name

          resources {
            limits = {
              cpu    = each.value.cpu_limit
              memory = each.value.memory_limit
            }
            requests = {
              cpu    = each.value.cpu_request
              memory = each.value.memory_request
            }
          }
        }

        service_account_name = each.value.service_account_name
      }
    }
  }
}
