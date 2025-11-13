# =========================================
# AWS APPLICATION LOAD BALANCER TARGET GROUP
# =========================================
# Target Group para distribuir tráfego entre as tasks ECS

resource "aws_alb_target_group" "main" {
  # Nome do target group baseado no cluster e serviço
  name = substr(format("%s-%s", var.cluster_name, var.service_name), 0, 32)

  # Porta onde o target group receberá tráfego
  port = var.service_port
  # VPC onde o target group será criado
  vpc_id = var.vpc_id

  # Protocolo de comunicação
  protocol = "HTTP"
  # Tipo de target - "ip" é necessário para Fargate
  target_type = "ip"

  # Configurações de health check
  health_check {
    # Número de health checks consecutivos bem-sucedidos para considerar target saudável
    healthy_threshold = lookup(var.service_healthcheck, "healthy_threshold", "3")

    # Número de health checks consecutivos falhos para considerar target não-saudável
    unhealthy_threshold = lookup(var.service_healthcheck, "unhealthy_threshold", "10")

    # Timeout para cada health check
    timeout = lookup(var.service_healthcheck, "timeout", "10")

    # Intervalo entre health checks
    interval = lookup(var.service_healthcheck, "interval", "10")

    # Códigos de resposta HTTP considerados como sucesso
    matcher = lookup(var.service_healthcheck, "matcher", "200")

    # Caminho para health check
    path = lookup(var.service_healthcheck, "path", "/")

    # Porta para health check (por padrão, mesma porta do serviço)
    port = lookup(var.service_healthcheck, "port", var.service_port)
  }

  lifecycle {
    create_before_destroy = false
  }
}