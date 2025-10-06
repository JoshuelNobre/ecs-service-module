# =========================================
# OUTPUTS DO MÓDULO ECS SERVICE
# =========================================
# Valores que serão retornados após a criação dos recursos

# ARN do serviço ECS criado
output "ecs_service_arn" {
  description = "ARN do serviço ECS criado"
  value       = aws_ecs_service.main.id
}

# Nome do serviço ECS criado
output "ecs_service_name" {
  description = "Nome do serviço ECS criado"
  value       = aws_ecs_service.main.name
}

# ARN da task definition criada
output "ecs_task_definition_arn" {
  description = "ARN da task definition criada"
  value       = aws_ecs_task_definition.main.arn
}

# Revisão da task definition
output "ecs_task_definition_revision" {
  description = "Revisão atual da task definition"
  value       = aws_ecs_task_definition.main.revision
}

# URL do repositório ECR criado
output "ecr_repository_url" {
  description = "URL do repositório ECR para push de imagens"
  value       = aws_ecr_repository.main.repository_url
}

# Nome do repositório ECR criado
output "ecr_repository_name" {
  description = "Nome do repositório ECR criado"
  value       = aws_ecr_repository.main.name
}

# ARN do target group criado
output "target_group_arn" {
  description = "ARN do target group do ALB criado"
  value       = aws_alb_target_group.main.arn
}

# Nome do target group criado
output "target_group_name" {
  description = "Nome do target group do ALB criado"
  value       = aws_alb_target_group.main.name
}

# ID do security group criado
output "security_group_id" {
  description = "ID do security group criado para o serviço"
  value       = aws_security_group.main.id
}

# Nome do security group criado
output "security_group_name" {
  description = "Nome do security group criado para o serviço"
  value       = aws_security_group.main.name
}

# ARN da role IAM de execução criada
output "execution_role_arn" {
  description = "ARN da role IAM de execução criada para as tasks"
  value       = aws_iam_role.service_execution_role.arn
}

# Nome da role IAM de execução criada
output "execution_role_name" {
  description = "Nome da role IAM de execução criada para as tasks"
  value       = aws_iam_role.service_execution_role.name
}

# Nome do log group do CloudWatch criado
output "cloudwatch_log_group_name" {
  description = "Nome do log group do CloudWatch criado para o serviço"
  value       = aws_cloudwatch_log_group.main.name
}

# ARN do log group do CloudWatch criado
output "cloudwatch_log_group_arn" {
  description = "ARN do log group do CloudWatch criado para o serviço"
  value       = aws_cloudwatch_log_group.main.arn
}

# ARN da regra do listener criada
output "listener_rule_arn" {
  description = "ARN da regra do listener do ALB criada"
  value       = aws_alb_listener_rule.main.arn
}