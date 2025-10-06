# =========================================
# AWS ECR REPOSITORY
# =========================================
# Repositório ECR para armazenar as imagens Docker do serviço

resource "aws_ecr_repository" "main" {
  # Nome do repositório seguindo padrão cluster/serviço
  name = format("%s/%s", var.cluster_name, var.service_name)

  # Se tiver true, permite deletar o repositório mesmo com imagens (útil para desenvolvimento)
  force_delete = false

  # Configuração de escaneamento de segurança das imagens
  image_scanning_configuration {
    # Escaneia automaticamente imagens quando são enviadas para o repositório
    scan_on_push = true
  }
}