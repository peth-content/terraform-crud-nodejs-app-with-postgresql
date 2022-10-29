vpc_name = "example"
vpc_cidr_block = "10.100.0.0/16"
app_subnets_cidr_block = ["10.100.0.0/20", "10.100.16.0/20", "10.100.32.0/20", "10.100.48.0/20"]
pub_subnets_cidr_block = ["10.100.200.0/22", "10.100.204.0/22"]
tags = {
    "Owner"       = "Example Test"
    "Account"     = "Sandbox"
    "Environment" = "Sandbox"
    "Iac"         = "Terraform"
    "Product"     = "Example"
}