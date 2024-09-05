variable "addons" {
  type = list(object({
    name    = string
    version = string
  }))

  default = [
    {
      name    = "kube-proxy"
      version = "v1.25.16-eksbuild.8"
    },
    {
      name    = "vpc-cni"
      version = "v1.18.3-eksbuild.1"
    }
  ]
}

variable "region" {
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
  default = "my-eks-cluster"
}

variable "cluster_version" {
  description = "EKS cluster version"
  type = string
  default = "1.21"
}




variable "vpc_id" {
  description = "VPC ID"
  type = string
}

variable "subnet_ids"{
    description = "subnet ID"
     type = list(string)
}


variable "ksa_name"{
    description = "name of the ksa"
    type  = string
}


variable "node_groups" {
  description = "Map of node group definitions to create"
  type = map(object({
    node_group_name       = string
    subnet_ids            = list(string)
    instance_types        = list(string)
    desired_capacity      = number
    max_capacity          = number
    min_capacity          = number
  }))
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
}