# Setup AWS credentials for API calls
provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region = "${var.region}"
}

# A public key to include in the ~/.ssh/authorized_keys on each node
resource "aws_key_pair" "cluster-key-pair" {
  key_name = "${var.key_name}"
  public_key = "${file(var.public_key_path)}"
}

# The virtual private cloud to host the cluster in
resource "aws_vpc" "cluster-vpc" {
  cidr_block = "10.20.0.0/16"

  # this is required to allow accessing instance within the VPC by their hostname
  enable_dns_hostnames = true

  tags {
    Name = "${var.g2ops_cluster_name} VPC"
    G2OpsOwner = "${var.g2ops_owner}"
    ExperoClusterName = "${var.g2ops_cluster_name}"
    ExpireAfterDate = "${var.expire_after_date}"
  }
}

# create an internet gateway for communication to and from the vpc and the internet
resource "aws_internet_gateway" "cluster-ig" {
  vpc_id = "${aws_vpc.cluster-vpc.id}"

  tags {
    Name = "${var.g2ops_cluster_name} IG"
    G2OpsOwner = "${var.g2ops_owner}"
    ExperoClusterName = "${var.g2ops_cluster_name}"
    ExpireAfterDate = "${var.expire_after_date}"
  }
}

# allow the vpc outbound internet access
resource "aws_route" "cluster-vpc-route" {
  route_table_id = "${aws_vpc.cluster-vpc.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = "${aws_internet_gateway.cluster-ig.id}"
}

# Create a subnet to launch our instances into
resource "aws_subnet" "cluster-subnet" {
  vpc_id                  = "${aws_vpc.cluster-vpc.id}"
  cidr_block              = "10.20.1.0/24"
  map_public_ip_on_launch = true

  depends_on = ["aws_internet_gateway.cluster-ig"]
}

# Security group for OpsCenter DSE cluster
resource "aws_security_group" "cluster-sg" {
  name = "${var.g2ops_cluster_name} SG"
  vpc_id = "${aws_vpc.cluster-vpc.id}"

  # SSH access from anywhere
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # unencrypted access to OpsCenter, required only for access until SSL is available
  ingress {
    from_port = 8888
    to_port = 8888
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Encrypted access to OpsCenter
  ingress {
    from_port = 8443
    to_port = 8443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Access to DSE
  ingress {
    from_port = 9042
    to_port = 9042
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # DSE inter-node
  ingress {
    from_port = 7000
    to_port = 7000
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # DSE inter-node SSL
  ingress {
    from_port = 7001
    to_port = 7001
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # DSE client port (trift)
  ingress {
    from_port = 9160
    to_port = 9160
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # DSE Spark Master inter-node port
  ingress {
    from_port = 7077
    to_port = 7077
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # DSE inter-node messaging service
  ingress {
    from_port = 8609
    to_port = 8609
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # JMX Monitoring
  ingress {
    from_port = 7199
    to_port = 7199
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Access From within subnet, no filtering
  ingress {
    from_port = 0
    to_port = 0
    protocol = -1
    self = true
  }

  # outbound internet access, required b/c tf removes the default allow all outbound rule
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# DSE Seed Node
resource "aws_instance" "dse_cluster_seed" {
  ami = "${lookup(var.amis, var.region)}"
  instance_type = "${var.instance_type_dse_max}"
  key_name = "${aws_key_pair.cluster-key-pair.id}"

  vpc_security_group_ids = ["${aws_security_group.cluster-sg.id}"]
  subnet_id = "${aws_subnet.cluster-subnet.id}"

  monitoring = true
  associate_public_ip_address = true
  count = "${var.seed_node_count}"

  tags {
    Name = "${var.g2ops_cluster_name}_seednode_node${count.index}"
    is_dse_seed_node = 1
    is_dse_node = 1
    is_cassandra_node = 1
    G2OpsOwner = "${var.g2ops_owner}"
    G2OpsClusterName = "${var.g2ops_cluster_name}"
    ExpireAfterDate = "${var.expire_after_date}"
  }
}

# DSE
resource "aws_instance" "dse_cluster_node" {
  ami = "${lookup(var.amis, var.region)}"
  instance_type = "${var.instance_type_dse_max}"
  key_name = "${aws_key_pair.cluster-key-pair.id}"

  vpc_security_group_ids = ["${aws_security_group.cluster-sg.id}"]
  subnet_id = "${aws_subnet.cluster-subnet.id}"

  monitoring = true
  associate_public_ip_address = true
  count = "${var.total_node_count - var.seed_node_count}"

  tags {
    Name = "${var.g2ops_cluster_name}_nodeonly_node${var.seed_node_count + count.index}"
    is_dse_seed_node = 0
    is_dse_node = 1
    is_cassandra_node = 1
    G2OpsOwner = "${var.g2ops_owner}"
    G2OpsClusterName = "${var.g2ops_cluster_name}"
    ExpireAfterDate = "${var.expire_after_date}"
  }
}
