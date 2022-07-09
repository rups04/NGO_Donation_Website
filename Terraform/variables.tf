variable "region" {
  description = "region for the infrastructure"
  default     = "ap-south-1"
}

variable "profile" {
  description = "aws credential profile"
  default     = "Rupali"
}

variable "key_name" {
  description = "ssh key"
  default     = "Project-key"
}

variable "security_group" {
  description = "Security Group name"
  default     = "major-project-security-rule"
}

variable "vpc_id" {
  description = "Vpc ID"
  default     = "vpc-da213db2"
}

variable "ami" {
  description = "Id of amazon machine image"
  default     = "ami-0447a12f28fddb066"
}

variable "instance_type" {
  description = "Type of amazon instance"
  default     = "t2.micro"
}

variable "instance_name" {
  description = "Name of amazon instance"
  default     = "webserver"
}

variable "ebs" {
  description = "Name of ebs volume"
  default     = "new_ebs"
}

variable "Github" {
  description = "Name of github repository"
  default     = "https://github.com/rups04/NGO_Donation_Website.git"
  #default     = "https://github.com/johnpapa/node-hello.git"
  #default     =  "https://github.com/rups04/To_Do_List.git"
}

variable "js_file" {
  description = "name of the js file"
  default     = "app.js"
 # default     = "index.js"
}



