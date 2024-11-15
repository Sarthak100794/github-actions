variable "aws_region" {
  description = "AWS region"
  type = string
  default = "us-west-2"
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type = string
  default = "10.0.0.0/16"
}

variable "private_subnets" {
  description = "Private subnet CIDR blocks"
  type = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

 variable "public_subnets" {
   description = "Public subnet CIDR blocks"
   type = list(string)
   default = ["10.0.3.0/24", "10.0.4.0/24"]
 }

variable "cluster_name" {
  description = "EKS cluster name"
  type = string
  default = "par-eks-cluster"
}

variable "cluster_version" {
  description = "EKS cluster version"
  type = string
  default = "1.25"
}

variable "node_group_name" {
  description = "EKS node group name"
  type = string
  default = "par-eks-node-group"
}

variable "node_group_instance_types" {
  description = "EKS node group instance types"
  type = list(string)
  default = ["t2.medium"]
}

variable "desired_capacity" {
  description = "Desired number of nodes"
  type = number
  default = 2
}

variable "min_size" {
  description = "Minimum number of nodes"
  type = number
  default = 1
}

variable "max_size" {
  description = "Maximum number of nodes"
  type = number
  default = 3
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket"
  type = string
  default = "gsc-addons"
}

variable "ksa_name"{
    type = string
    default = "par-ksa"
}

variable "node_groups" {
  description = "Map of node group definitions to create node group"
  type = map(object({
    node_group_name       = string
    subnet_ids            = list(string)
    instance_types        = list(string)
    desired_capacity      = number
    max_capacity          = number
    min_capacity          = number
  }))
  default = {
    group1 = {
      node_group_name  = "group1"
      subnet_ids       = ["subnet-0ffefb56b81bcd554", "subnet-0a71cffdd853e0f8a"]
      instance_types   = ["t3.medium"]
      desired_capacity = 1
      max_capacity     = 3
      min_capacity     = 1
    }
  }
}


variable "deployments" {
  description = "Map of deployment definitions to create"
  type = map(object({
    name                = string
    labels              = map(string)
    image               = string
    container_name      = string
    replicas            = number
    cpu_limit           = string
    memory_limit        = string
    cpu_request         = string
    memory_request      = string
    service_account_name = string
  }))
  default = {
    dep1 = {
      name                = "par-dep1"
      labels              = { Name = "dep1" }
      image               = "nginx:1.21.6"
      container_name      = "container1"
      replicas            = 1
      cpu_limit           = "0.5"
      memory_limit        = "512Mi"
      cpu_request         = "250m"
      memory_request      = "50Mi"
      service_account_name = "par-ksa"
    }
    dep2 = {
      name                = "par-dep2"
      labels              = { Name = "dep2" }
      image               = "nginx:1.21.6"
      container_name      = "container2"
      replicas            = 1
      cpu_limit           = "0.5"
      memory_limit        = "512Mi"
      cpu_request         = "250m"
      memory_request      = "50Mi"
      service_account_name = "par-ksa"
    }
  }
}
