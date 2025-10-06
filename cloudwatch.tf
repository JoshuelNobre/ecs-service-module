# =========================================
# AWS CLOUDWATCH LOG GROUP
# =========================================
# Grupo de logs do CloudWatch para armazenar logs das tasks ECS

resource "aws_cloudwatch_log_group" "main" {
  # Nome do log group seguindo padrão cluster/serviço/logs
  name = format("%s/%s/logs", var.cluster_name, var.service_name)

  # Opcional: definir período de retenção dos logs (não especificado = logs ficam indefinidamente)
  # retention_in_days = 30
}