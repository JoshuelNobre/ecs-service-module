# =========================================
# AWS AUTO SCALING POLICY - TARGET TRACKING CPU
# =========================================
# Policy de auto scaling baseada em tracking de CPU
# Esta policy automaticamente escala o serviço ECS baseado na utilização média de CPU

resource "aws_appautoscaling_policy" "target_tracking_cpu" {
  # Só cria este recurso se o tipo de scaling for "cpu_tracking"
  count = var.scale_type == "cpu_tracking" ? 1 : 0
  
  # Nome da policy seguindo padrão cluster-serviço-cpu-tracking
  name = format("%s-%s-cpu-tracking", var.cluster_name, var.service_name)
  
  # Referências ao target de autoscaling (serviço ECS)
  resource_id        = aws_appautoscaling_target.main.resource_id        # service/cluster/service-name
  scalable_dimension = aws_appautoscaling_target.main.scalable_dimension # ecs:service:DesiredCount
  service_namespace  = aws_appautoscaling_target.main.service_namespace  # ecs
  
  # Tipo de policy - Target Tracking mantém uma métrica próxima a um valor alvo
  policy_type = "TargetTrackingScaling"

  # Configuração da policy de target tracking
  target_tracking_scaling_policy_configuration {
    # Valor alvo de utilização de CPU (em porcentagem, ex: 70.0 = 70%)
    # Quando a CPU média exceder este valor, novas tasks serão criadas
    # Quando a CPU média ficar abaixo deste valor, tasks serão removidas
    target_value = var.scale_tracking_cpu
    
    # Tempo de cooldown para scale-in (diminuir tasks) em segundos
    # Evita que o serviço diminua muito rapidamente após um scale-in
    scale_in_cooldown = var.scale_in_cooldown
    
    # Tempo de cooldown para scale-out (aumentar tasks) em segundos
    # Evita que o serviço aumente muito rapidamente após um scale-out
    scale_out_cooldown = var.scale_out_cooldown

    # Especificação da métrica predefinida do AWS
    predefined_metric_specification {
      # Métrica de utilização média de CPU do serviço ECS
      # AWS automaticamente calcula a média de CPU de todas as tasks do serviço
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
  }
}