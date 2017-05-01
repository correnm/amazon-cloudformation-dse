# AWS Access Key
variable "access_key" {}

# AWS Secret Key
variable "secret_key" {}

# G2 Ops AWS Mgmt Tags
variable "g2ops_owner" {}
variable "expire_after_date" {}

variable "g2ops_cluster_name" {
  default = "DSE Test Cluster"
}

# The path to the ssh public key to associate with the instances
variable "public_key_path" {
  default = "~/.ssh/MyRsaKey.pub"
}

# The name to associate the public key with
variable "key_name" {
  default = "MyRsaKey"
}

# the region to provision the infrastructure in
variable "region" {
  default = "us-west-2"
}

# the defeault availability zone for instances within the region
variable "region_zone" {
  default = "us-west-2a"
}

# the instance type of the instances to provision
variable "instance_type_dse_max" {
  default = "m4.large"
}

variable "instance_type_opscenter" {
  default = "t2.large"
}

# map of regions to the ami to use within that region
# us-west-2 = Ubuntu Server 16.04 LTS (HVM), SSD Volume Type - ami-efd0428f
variable "amis" {
  type = "map"
  default = {
    us-west-2 = "ami-efd0428f"
  }
}

# recommend > 1 seed nodes
variable "seed_node_count" {
  default = 2
}

# Must be >= seed_node_count
variable "total_node_count" {
  default = 5
}