resource "aws_security_group" "nodejs_sg" {
  name        = "Nodejs Security Group"
  description = "Security group for NodeJS servers"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port   = 22
    to_port     = 22 
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080 
    protocol    = "tcp"
    security_groups = [aws_security_group.varnish_sg.id]
    # security_groups = ["${aws_security_group.varnish_sg.id}"]
    # cidr_blocks = ["${aws_instance.varnish_server.public_ip}/32"]
  }

  

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}


resource "aws_security_group" "varnish_sg" {
  name        = "Varnish Security Group"
  description = "Security group for Varnish server"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 6081
    to_port     = 6081
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "mysql_sg" {
  name        = "MySql Security Group"
  description = "Security group for MySQL server"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port   = 22
    to_port     = 22 
    protocol    = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3306
    to_port     = 3306 
    protocol    = "tcp"
    security_groups = [aws_security_group.nodejs_sg.id]
}

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}


resource "aws_instance" "varnish_server" {
  ami             = "${var.ami}"
  instance_type   = "${var.instance_type}"
  vpc_security_group_ids = [aws_security_group.varnish_sg.id]
  subnet_id       = "${var.subnet_id}"
  key_name        = "${var.key_name}"

  tags =  {
    Name = "varnish_server"
    Group = "varnish_servers"
  }

  connection {
    user = "centos"
    host = "${aws_instance.varnish_server.public_ip}"
    private_key = "${file("/Users/chiobi/sportbook_git/ansible/chiobi/devOpsRotation/private.pem")}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo hostnamectl set-hostname varnish_server",
    ]
  }

}

resource "aws_instance" "nodejs_server1" {
  ami             = "${var.ami}"
  instance_type   = "${var.instance_type}"
  vpc_security_group_ids = [aws_security_group.nodejs_sg.id] 
  subnet_id       = "${var.subnet_id}"
  key_name        = "${var.key_name}"

  tags = {
    Name = "nodejs_server1"
    Group = "nodejs_servers"
  }

  connection {
    user = "centos"
    host = "${aws_instance.nodejs_server1.public_ip}"
    private_key = "${file("/Users/chiobi/sportbook_git/ansible/chiobi/devOpsRotation/private.pem")}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo hostnamectl set-hostname nodejs_server1",
    ]
  }
}

resource "aws_instance" "nodejs_server2" {
  ami             = "${var.ami}"
  instance_type   = "${var.instance_type}"
  vpc_security_group_ids = [aws_security_group.nodejs_sg.id]
  subnet_id       = "${var.subnet_id}"
  key_name        = "${var.key_name}"

  tags = {
    Name = "nodejs_server2"
    Group = "nodejs_servers"
  }

  connection {
    user = "centos"
    host = "${aws_instance.nodejs_server2.public_ip}"
    private_key = "${file("/Users/chiobi/sportbook_git/ansible/chiobi/devOpsRotation/private.pem")}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo hostnamectl set-hostname nodejs_server2",
    ]
  }
}

resource "aws_instance" "mysql_server" {
  ami             = "${var.ami}"
  instance_type   = "${var.instance_type}"
  vpc_security_group_ids = [aws_security_group.mysql_sg.id]
  subnet_id       = "${var.subnet_id}"
  key_name        = "${var.key_name}"
  
  tags = {
    Name = "mysql_server"
    Group = "mysql_servers"
  }

  connection {
    user = "centos"
    host = "${aws_instance.mysql_server.public_ip}"
    private_key = "${file("/Users/chiobi/sportbook_git/ansible/chiobi/devOpsRotation/private.pem")}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo hostnamectl set-hostname mysql_server",
    ]
  }
}
