data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "nginx-Server" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  key_name               = "Devops-Kp"
  vpc_security_group_ids = [aws_security_group.mysg.id]

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y nginx",
      "echo 'It Works!' | sudo tee /var/www/html/index.html",
      "sudo systemctl start nginx",
      "sudo systemctl enable nginx"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(pathexpand("~/Downloads/Devops-Kp.pem"))
      host        = self.public_ip
    }
  }

  provisioner "local-exec" {
    interpreter = ["PowerShell", "-NoProfile", "-Command"]
    command     = <<-EOT
      $url = "http://${self.public_ip}"
      for ($attempt = 1; $attempt -le 12; $attempt++) {
        try {
          $response = Invoke-WebRequest -UseBasicParsing -Uri $url
          if ($response.StatusCode -eq 200) {
            Write-Output $response.Content
            exit 0
          }
        } catch {
        }
        Start-Sleep -Seconds 5
      }
      throw "Nginx did not return HTTP 200 at $url"
    EOT
  }
}