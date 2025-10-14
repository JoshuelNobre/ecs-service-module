# =========================================
# AWS ECS TASK DEFINITION
# =========================================
# Este recurso define como o container será executado no ECS

resource "aws_ecs_task_definition" "main" {
  # Nome da família da task definition (combinação do cluster e serviço)
  family = format("%s-%s", var.cluster_name, var.service_name)

  # Modo de rede para tasks Fargate (sempre awsvpc)
  network_mode = "awsvpc"

  # Capacidades requeridas (FARGATE, EC2, etc.)
  requires_compatibilities = var.capabilities

  # Recursos de CPU e memória para a task
  cpu    = var.service_cpu
  memory = var.service_memory

  # Role IAM para execução da task (para acessar ECR, CloudWatch logs, etc.)
  execution_role_arn = aws_iam_role.service_execution_role.arn

  # Role IAM que a aplicação dentro do container usará
  task_role_arn = var.service_task_execution_role

  # Definição dos containers em formato JSON
  container_definitions = jsonencode([
    {
      # Nome do container
      name = var.service_name

      # Imagem do container (usando a imagem latest do ECR - existente ou criado)
      image  = "550094086634.dkr.ecr.us-east-1.amazonaws.com/linux-tips-ecs-cluster/chip:latest"

      # Recursos de CPU e memória do container
      cpu    = var.service_cpu
      memory = var.service_memory

      # Container essencial - se falhar, a task toda falha
      essential = true

      # Mapeamento de portas
      portMappings = [
        {
          name          = var.service_name
          containerPort = var.service_port
          hostPort      = var.service_port
        }
      ]

      # Configuração de logs para CloudWatch
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.main.id
          awslogs-region        = var.region
          awslogs-stream-prefix = var.service_name
        }
      }

      # Variáveis de ambiente passadas para o container
      environment = var.environment_variables
    }
  ])
}