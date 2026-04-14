variable "ami" {}
variable "subnet_id" {}
variable "sg_id" {
  type = string
}
variable "user_data" {}
variable "name" {}
variable "instance_type" {
  default = "t3.micro"
}
variable "key_name" {}