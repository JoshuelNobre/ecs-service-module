# =========================================
# AWS APPLICATION LOAD BALANCER LISTENER RULE
# =========================================
# Regra do listener do ALB para rotear tráfego para o target group

resource "aws_alb_listener_rule" "main" {
  # ARN do listener do ALB onde a regra será anexada
  listener_arn = var.service_listener

  # Ação a ser tomada quando a regra for correspondida
  action {
    # Tipo de ação - encaminhar tráfego para o target group
    type = "forward"
    # Target group de destino
    target_group_arn = aws_alb_target_group.main.arn
  }

  # Condição para ativar a regra - baseada no header Host
  condition {
    host_header {
      # Lista de hosts/domínios que ativarão esta regra
      values = var.service_hosts
    }
  }

  # # Lifecycle - cria nova regra antes de destruir a antiga
  # # Isso evita downtime durante atualizações
  # lifecycle {
  #   create_before_destroy = true
  # }
}