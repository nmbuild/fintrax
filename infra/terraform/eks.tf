# EKS Cluster - Basic Infrastructure First
# TODO: Add EKS cluster after basic infrastructure is working

# For now, let's use a simple EC2 instance to host our applications
resource "aws_instance" "k8s_node" {
  ami                    = var.ami_id
  instance_type          = "t3.medium"
  subnet_id              = aws_subnet.main.id
  vpc_security_group_ids = [aws_security_group.main.id]
  
  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y docker
    systemctl start docker
    systemctl enable docker
    usermod -aG docker ec2-user
    
    # Install kubectl
    curl -o kubectl https://amazon-eks.s3.us-west-2.amazonaws.com/1.18.9/2020-11-02/bin/linux/amd64/kubectl
    chmod +x ./kubectl
    sudo mv ./kubectl /usr/local/bin
    
    # Install k3s (lightweight kubernetes)
    curl -sfL https://get.k3s.io | sh -
  EOF

  tags = {
    Name        = "fintrax-k8s-node"
    Environment = "development"
  }
}
