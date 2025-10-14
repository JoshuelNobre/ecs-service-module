# # =========================================
# # AWS ECR REPOSITORY
# # =========================================
# # Repositório ECR para armazenar as imagens Docker do serviço

# # Data source para usar ECR existente (se já existir)
# data "aws_ecr_repository" "existing" {
#   count = var.use_existing_ecr ? 1 : 0
#   name  = format("%s/%s", var.cluster_name, var.service_name)
# }

# # Resource para criar novo ECR (se não existir)
# resource "aws_ecr_repository" "main" {
#   count = var.use_existing_ecr ? 0 : 1

#   # Nome do repositório seguindo padrão cluster/serviço
#   name = format("%s/%s", var.cluster_name, var.service_name)

#   # Se tiver true, permite deletar o repositório mesmo com imagens (útil para desenvolvimento)
#   force_delete = true

#   # Configuração de escaneamento de segurança das imagens
#   image_scanning_configuration {
#     # Escaneia automaticamente imagens quando são enviadas para o repositório
#     scan_on_push = true
#   }
# }

# # Local para unificar a referência ao ECR (existente ou novo)
# locals {
#   ecr_repository_url  = var.use_existing_ecr ? data.aws_ecr_repository.existing[0].repository_url : aws_ecr_repository.main[0].repository_url
#   ecr_repository_name = var.use_existing_ecr ? data.aws_ecr_repository.existing[0].name : aws_ecr_repository.main[0].name
# }