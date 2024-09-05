variable "cidr_block" {
  description = "VPC CIDR block"
  type = string
}

variable "private_subnets" {
  description = "Private subnet CIDR blocks"
  type = list(string)
}

 variable "public_subnets" {
   description = "Public subnet CIDR blocks"
   type = list(string)
 }
