provider "aws" {
  version = "~>3.0"
  region = "us-east-1"
}
resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/24"
}
resource "aws_subnet" "subnet" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.0.0.0/24"
  map_public_ip_on_launch = true
}
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
}
resource "aws_route_table" "routtable" {
  vpc_id = aws_vpc.vpc.id
}
resource "aws_route_table_association" "asso" {
  route_table_id = aws_route_table.routtable.id
  subnet_id = aws_subnet.subnet.id
}
resource "aws_route" "route" {
  route_table_id = aws_route_table.routtable.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.igw.id
}
resource "aws_security_group" "sg" {
  vpc_id = aws_vpc.vpc.id
  ingress {
    from_port = 0
    protocol  = "-1"
    to_port   = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    protocol  = "-1"
    to_port   = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_key_pair" "key" {
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCwPY1VpBixvIJCIUMNz9pvT687FNPAa8hAw3t239SOfYAsy1lgRYyh2YF6ey7pMmo+u0TSSGFRMlqoolFoZNClFujMI31v3aUrhC+l4ppfGDuKNeaVztEkpAlh5ARN01aLyYtOSia/tZSvRl1BcVAWIEWsgbYhi/JFrMVhTBMYkvvK8uHKiJc0RRodCSJeCnCY7Bqa7TU3qMNA0h8lE4gSmvVSsel9tNPf16qnQjRGQS9Hn5FFPvccjP3DVihTq3ee3uxfSJ4/gABSDur8KIDMRU0CjbkUk/KnKDYUecMuKoYdPvV1hiKWI9YljqUxQDSSCMFNlMOrLwZNU35+nCTJH3hC2aaQb9/BAlKP2Xxyquk3am+ZHRINev1zjcmcDtLOvXtYOtY5e9P7drgQ9chFvoB3geNGIdvhU2/nHei7YNA26z4uc8qPL/9H1+MDJORLy9U06JZVRBOC36OmtjGKSx6R5HT2aezM7OmHljk00qKAcY9neLo6xAne9tWrs7c= ashiq@INBook_X1"
}
resource "aws_instance" "ec2" {
  ami = "ami-0b0dcb5067f052a63"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.subnet.id
  security_groups = [aws_security_group.sg.id]
  key_name = aws_key_pair.key.id
  provisioner "remote-exec" {
    inline = ["sudo yum install httpd -y",
              "sudo systemctl start httpd"
    ]
  }
  connection {
    type = "ssh"
    host = aws_instance.ec2.public_ip
    user = "ec2-user"
    private_key = file ("C:/Users/ashiq/.ssh/id_rsa")
  }
  lifecycle {
    create_before_destroy = true
  }
  tags = {
    Name = "terraformec2"
  }
}
output "ec2-pub-ip" {
  value = aws_instance.ec2.public_ip
}