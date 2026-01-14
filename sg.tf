# =========================================
# AWS SECURITY GROUP
# =========================================
# Security Group para controlar o tráfego de rede das tasks ECS

resource "aws_security_group" "main" {
  # Nome do security group baseado no cluster e serviço
  name = format("%s-%s", var.cluster_name, var.service_name)

  # VPC onde o security group será criado
  vpc_id = var.vpc_id

  # Regra de entrada - permite tráfego na porta do serviço
  ingress {
    from_port = var.service_port
    to_port   = var.service_port
    protocol  = "tcp"
    # ATENÇÃO: 0.0.0.0/0 permite acesso de qualquer lugar
    # Em produção, considere restringir para CIDRs específicos ou security groups do ALB
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  ingress {
    from_port = 0
    to_port   = 65535
    protocol  = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  # Regra de saída - permite todo tráfego de saída
  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1" # -1 significa todos os protocolos
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }
}