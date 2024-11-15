
#provider "kubernetes" {
#  host                   = module.eks.cluster_endpoint
#  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
#  token                  = data.aws_eks_cluster_auth.main.token
#}

#data "aws_eks_cluster_auth" "main" {
#  name = module.eks.cluster_name
#}
 
#  module "vpc" {
#    source = "./modules/vpc"
#    cidr_block = var.vpc_cidr
#    private_subnets = var.private_subnets
#    public_subnets = var.public_subnets
# }

# module "eks" {
#   source = "./modules/eks"
#   cluster_name = var.cluster_name
#   cluster_version = var.cluster_version
#   vpc_id = module.vpc.vpc_id
#   subnet_ids = module.vpc.private_subnets
#   node_groups = var.node_groups
#   ksa_name    = var.ksa_name
#   deployments  = var.deployments
# }

resource "aws_s3_bucket" "main" {
  bucket = "gsc-plugin-postsales"


}



