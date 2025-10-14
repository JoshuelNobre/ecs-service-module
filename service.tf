# =========================================
# AWS ECS SERVICE
# =========================================
# Este recurso cria o serviço ECS que gerencia as tasks do container

resource "aws_ecs_service" "main" {
  # Nome do serviço ECS
  name = var.service_name

  # Cluster onde o serviço será executado
  cluster = var.cluster_name

  # Definição da task que será executada
  task_definition = aws_ecs_task_definition.main.arn

  # Número desejado de tasks em execução
  desired_count = var.service_task_count

  # Tipo de lançamento (FARGATE ou EC2)
  # launch_type = var.service_launch_type

  # Configurações de deployment
  # Permite até 200% das tasks durante o deployment (para zero downtime)
  deployment_maximum_percent = 200
  # Mantém pelo menos 100% das tasks saudáveis durante o deployment
  deployment_minimum_healthy_percent = 100

  # Circuit breaker para deployment - rollback automático em caso de falha
  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

dynamic "capacity_provider_strategy" {
    for_each = var.service_launch_type
    content {
      capacity_provider = capacity_provider_strategy.value.capacity_provider
      weight            = capacity_provider_strategy.value.weight
    }
  }

  dynamic "ordered_placement_strategy" {
    for_each = var.service_launch_type == "EC2" ? [1] : []
    content {
      type  = "spread"
      field = "attribute:ecs.availability-zone"
    }
  }

  # Configuração de rede para tasks Fargate
  network_configuration {
    # Security groups que controlam o tráfego de rede
    security_groups = [
      aws_security_group.main.id
    ]

    # Subnets privadas onde as tasks serão executadas
    subnets = var.private_subnets

    # Não atribui IP público (tasks em subnet privada)
    assign_public_ip = false
  }

  # Configuração do load balancer
  load_balancer {
    # Target group para distribuição de tráfego
    target_group_arn = aws_alb_target_group.main.arn
    # Nome do container na task definition
    container_name = var.service_name
    # Porta do container
    container_port = var.service_port
  }

  # Lifecycle - ignora mudanças no desired_count (para permitir auto scaling)
  lifecycle {
    ignore_changes = [
      desired_count
    ]
  }

  # Versão da plataforma Fargate (comentado para usar a versão LATEST automaticamente)
  # platform_version = "LATEST"

  # Dependências (vazio por enquanto, mas pode ser usado para ordenar criação de recursos)
  depends_on = []
}