resource "aws_appautoscaling_target" "main" {
  # Tipo de recurso a ser escalado (no caso, serviço ECS)
  resource_id        = format("service/%s/%s", var.cluster_name, var.service_name)
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"

  # Configuração de escalabilidade
  min_capacity = var.task_minimum
  max_capacity = var.task_maximum

  # Dependência explícita do serviço ECS
  depends_on = [aws_ecs_service.main]
}