resource "aws_appautoscaling_policy" "target_tracking_requests" {
  # Só cria este recurso se o tipo de scaling for "requests_tracking"
  count = var.scale_type == "requests_tracking" ? 1 : 0

  # Nome da policy seguindo padrão cluster-serviço-requests-tracking
  name = format("%s-%s-requests-tracking", var.cluster_name, var.service_name)

  # Referências ao target de autoscaling (serviço ECS)
  resource_id        = aws_appautoscaling_target.main.resource_id        # service/cluster/service-name
  scalable_dimension = aws_appautoscaling_target.main.scalable_dimension # ecs:service:DesiredCount
  service_namespace  = aws_appautoscaling_target.main.service_namespace  # ecs

  # Tipo de policy - Target Tracking mantém uma métrica próxima a um valor alvo
  policy_type = "TargetTrackingScaling"

  # Configuração da policy de target tracking
  target_tracking_scaling_policy_configuration {
    # Valor alvo de utilização de requests (em porcentagem, ex: 70.0 = 70%)
    # Quando a requests média exceder este valor, novas tasks serão criadas
    # Quando a requests média ficar abaixo deste valor, tasks serão removidas
    target_value = var.scale_tracking_requests

    # Tempo de cooldown para scale-in (diminuir tasks) em segundos
    # Evita que o serviço diminua muito rapidamente após um scale-in
    scale_in_cooldown = var.scale_in_cooldown

    # Tempo de cooldown para scale-out (aumentar tasks) em segundos
    # Evita que o serviço aumente muito rapidamente após um scale-out
    scale_out_cooldown = var.scale_out_cooldown

    # Especificação da métrica predefinida do AWS
    predefined_metric_specification {
      predefined_metric_type = "ALBRequestCountPerTarget"
      resource_label         = format("%s/%s", data.aws_alb.main.arn_suffix, aws_alb_target_group.main.arn_suffix)
    }
  }
}