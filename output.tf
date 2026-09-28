data "http" "nginx" {
  url        = "http://${aws_instance.nginx-Server.public_ip}"
  depends_on = [aws_instance.nginx-Server]
}

output "my-nginx-output" {
  value = aws_instance.nginx-Server.public_ip
}

output "my-nginx-url" {
  value = "http://${aws_instance.nginx-Server.public_ip}"
}

output "nginx-page-output" {
  value = trimspace(data.http.nginx.response_body)
}