# =========================================
# AWS IAM ROLES E POLICIES
# =========================================
# Recursos IAM necessários para execução das tasks ECS

# Role IAM para execução das tasks ECS
resource "aws_iam_role" "service_execution_role" {
  # Nome da role baseado no cluster e serviço
  name = format("%s-%s-service-role", var.cluster_name, var.service_name)

  # Policy que permite ao ECS assumir esta role
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Effect = "Allow"
        Sid    = ""
      },
    ]
  })
}

# Policy anexada à role com permissões necessárias para execução das tasks
resource "aws_iam_role_policy" "service_execution_role" {
  # Nome da policy baseado no cluster e serviço
  name = format("%s-%s-service-policy", var.cluster_name, var.service_name)

  # Role à qual esta policy será anexada
  role = aws_iam_role.service_execution_role.id

  # Permissões necessárias para o ECS executar tasks
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          # Permissões para Load Balancer
          "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
          "elasticloadbalancing:DeregisterTargets",
          "elasticloadbalancing:Describe*",
          "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
          "elasticloadbalancing:RegisterTargets",

          # Permissões EC2 para networking
          "ec2:Describe*",
          "ec2:AuthorizeSecurityGroupIngress",

          # Permissões ECR para baixar imagens
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",

          # Permissões CloudWatch Logs para logging
          "logs:CreateLogStream",
          "logs:PutLogEvents",

          # Permissões para acessar parâmetros e secrets
          "ssm:GetParameters",
          "secretsmanager:GetSecretValue"
        ],
        Resource = "*",
        Effect   = "Allow"
      },
    ]
  })
}