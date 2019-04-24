variable "K8MASTER" {}

variable "TOKEN" {}

variable "securitysg" { 
}

data "template_file" "userdata" {
  template = "${file("user-data.sh")}"
}

resource "random_shuffle" "subnet" {
  input = ["subnet-blah", "subnet-blah", "subnet-blah"]
}
