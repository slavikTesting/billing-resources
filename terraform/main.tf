terraform {
  # should not be billed
  required_version = ">= 0.12.6, < 0.14"
  required_providers {
    aws = ">= 2.42, < 4.0"
  }
}

provider "aws" {
  # should not be billed
  region = "us-west-2"
}

locals {
  content_zip = "my-awesome-content.zip"  # should not be billed
}

data "aws_caller_identity" "current" {
  # should not be billed
}


resource "azurerm_storage_blob" "example" {
  # This resource should not produce a violation but should be billed
  name                   = local.content_zip
  storage_account_name   = azurerm_storage_account.example.name
  storage_container_name = azurerm_storage_container.example.name
  type                   = "Block"
  source                 = "some-local-file.zip"
}

resource "aws_security_group" "allow_tcp" {
  # This resource should produce a violation but should be billed
  name = "allow_tcp"
  description = "Allow TCP inbound traffic"
  vpc_id = aws_vpc.foo_vpc.id
  // 6. AWS Security Groups allow internet traffic to SSH port (22)
  // $.resource[*].aws_security_group exists and ($.resource[*].aws_security_group[*].*[*].ingress[?( @.protocol == 'tcp' && @.from_port<23 && @.to_port>21 )].cidr_blocks[*] contains 0.0.0.0/0 or $.resource[*].aws_security_group[*].*[*].ingress[?( @.protocol == 'tcp' && @.from_port<23 && @.to_port>21 )].ipv6_cidr_blocks[*] contains ::/0)
  ingress {
    description = "TCP from VPC"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }
  // 31. AWS security group allows egress traffic to blocked ports - 21,22,135,137-139,445,69
  // $.resource[*].aws_security_group exists and $.resource[*].aws_security_group.*[*].*.egress[?(@.protocol == 'tcp' && @.from_port == '22' && @.to_port == '22')].cidr_blocks[*] == 0.0.0.0/0 or $.resource[*].aws_security_group.*[*].*.egress[?(@.protocol == 'tcp' && @.from_port == '22' && @.to_port == '22')].ipv6_cidr_blocks[*] == ::/0 or $.resource[*].aws_security_group.*[*].*.egress[?(@.protocol == 'tcp' && @.from_port == '21' && @.to_port == '21')].cidr_blocks[*] == 0.0.0.0/0 or $.resource[*].aws_security_group.*[*].*.egress[?(@.protocol == 'tcp' && @.from_port == '21' && @.to_port == '21')].ipv6_cidr_blocks[*] == ::/0 or $.resource[*].aws_security_group.*[*].*.egress[?(@.protocol == 'tcp' && @.from_port == '445' && @.to_port == '445')].cidr_blocks[*] == 0.0.0.0/0 or $.resource[*].aws_security_group.*[*].*.egress[?(@.protocol == 'tcp' && @.from_port == '445' && @.to_port == '445')].ipv6_cidr_blocks[*] == ::/0 or $.resource[*].aws_security_group.*[*].*.egress[?(@.protocol == 'udp' && @.from_port == '135' && @.to_port == '135')].cidr_blocks[*] == 0.0.0.0/0 or $.resource[*].aws_security_group.*[*].*.egress[?(@.protocol == 'udp' && @.from_port == '135' && @.to_port == '135')].ipv6_cidr_blocks[*] == ::/0 or $.resource[*].aws_security_group.*[*].*.egress[?(@.protocol == '-1' && @.from_port == '137' && @.to_port == '139')].cidr_blocks[*] == 0.0.0.0/0 or $.resource[*].aws_security_group.*[*].*.egress[?(@.protocol == '-1' && @.from_port == '137' && @.to_port == '139')].ipv6_cidr_blocks[*] == ::/0 or $.resource[*].aws_security_group.*[*].*.egress[?(@.protocol == 'udp' && @.from_port == '69' && @.to_port == '69')].cidr_blocks[*] == 0.0.0.0/0 or $.resource[*].aws_security_group.*[*].*.egress[?(@.protocol == 'udp' && @.from_port == '69' && @.to_port == '69')].ipv6_cidr_blocks[*] == ::/0
  egress {
    from_port = 69
    to_port = 69
    protocol = "udp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }
}

module "security_group" {
  # public module, should generate 22 resources
  source  = "terraform-aws-modules/security-group/aws"
  version = "3.18.0"

  name        = "example"
  description = "Security group for example usage with EC2 instance"
  vpc_id      = var.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp", "all-icmp"]
  egress_rules        = ["all-all"]
}

module "external_security_group" {
  # private github enterprise module, should generate 1 resource
  source  = "git@spring.paloaltonetworks.com:ravni/billing-testing.git"
}