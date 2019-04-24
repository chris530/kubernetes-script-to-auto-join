resource "aws_instance" "kubernetes_node" {
  count         = 1
  ami           = "${data.aws_ami.ubuntu.id}"
  instance_type = "c4.4xlarge"
  iam_instance_profile = "All"
  security_groups = ["${var.securitysg}"]
  subnet_id = "${random_shuffle.subnet.result[0]}"
  key_name = "production-key"
  user_data = "${file("user-data.sh")}"
  root_block_device {
    volume_size = "100"
    volume_type = "standard"
  }
  tags = {
    Name = "kubernetes-1.12-production-node"
    Worker = "shared"
    "kubernetes.io/cluster/production" = "shared"
    TOKEN = "${var.TOKEN}"
    K8MASTER = "${var.K8MASTER}"
  }

}
