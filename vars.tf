variable "vpc_name" {
  type = string
}
variable "vpc_cidr_block" {
  type = string
}
variable "app_subnets_cidr_block" {
  type = list(string)
}
variable "pub_subnets_cidr_block" {
  type = list(string)
}
variable "tags" {
  type = map(string)
}