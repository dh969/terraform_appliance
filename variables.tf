variable "input_command_1" {
  type        = string
  description = "First input command for the Azure Migrate Installer script"
  default     = "3"
}

variable "input_command_2" {
  type        = string
  description = "Second input command for the Azure Migrate Installer script"
  default     = "1"
}

variable "input_command_3" {
  type        = string
  description = "Third input command for the Azure Migrate Installer script"
  default     = "1"
}

variable "input_command_4" {
  type        = string
  description = "Fourth input command for the Azure Migrate Installer script"
  default     = "Y"
}
variable "region" {
  type = string
}
variable "ami" {
  type    = string
  default = "ami-07ef4004db979fcd4"
}
variable "instance_type" {
  type = string

}
variable "volume" {
  type = string
}
variable "availability" {
  type = string
}
variable "instance_name" {
  type = string
}
