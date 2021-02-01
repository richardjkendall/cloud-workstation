
source "amazon-ebs" "basic-ubuntu" {
  ami_name = "cws/ubuntu/20.04/basic"
  profile = "default"
  region = "ap-southeast-2"
  instance_type = "t3.large"  

  source_ami_filter {
    filters = {
      virtualization-type = "hvm"
      name =  "ubuntu/images/hvm-ssd/*ubuntu-focal-20.04-amd64-server-*"
      root-device-type = "ebs"
    }
    owners = ["099720109477"]
    most_recent = true
  }

  communicator = "ssh"
  ssh_username = "ubuntu"
}

build {
  sources = ["source.amazon-ebs.basic-ubuntu"]
  
  provisioner "shell" {
    script = "setup_vnc.sh"
  }

  provisioner "shell" {
    script = "setup_aws_cli.sh"
  }
}

