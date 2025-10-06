# Módulo Terraform - ECS Service

Este módulo Terraform cria uma infraestrutura completa para executar um serviço containerizado no Amazon ECS (Elastic Container Service) com Fargate, incluindo todos os recursos necessários para uma aplicação web escalável e segura.

## 🏗️ Arquitetura

O módulo cria os seguintes recursos AWS:

- **ECS Service**: Gerencia a execução das tasks do container
- **ECS Task Definition**: Define como o container será executado
- **ECR Repository**: Repositório para armazenar imagens Docker
- **Application Load Balancer Target Group**: Distribui tráfego entre as tasks
- **ALB Listener Rule**: Roteia tráfego baseado em hostnames
- **Security Group**: Controla acesso de rede às tasks
- **IAM Role e Policies**: Permissões necessárias para execução
- **CloudWatch Log Group**: Coleta logs das aplicações

## 📋 Pré-requisitos

- Terraform >= 0.14
- Provider AWS configurado
- VPC e subnets privadas existentes
- Application Load Balancer e listener existentes

## 🚀 Como usar

### Exemplo básico

```hcl
module "meu_servico_ecs" {
  source = "./ecs-service-module"

  # Configurações básicas
  region        = "us-east-1"
  service_name  = "minha-api"
  cluster_name  = "meu-cluster"

  # Rede
  vpc_id          = "vpc-12345678"
  private_subnets = ["subnet-12345678", "subnet-87654321"]

  # Recursos do container
  service_port   = 3000
  service_cpu    = 256
  service_memory = 512

  # Load Balancer
  service_listener = "arn:aws:elasticloadbalancing:us-east-1:123456789:listener/app/meu-alb/1234567890123456/1234567890123456"
  service_hosts    = ["api.meudominio.com"]

  # Configurações de execução
  service_task_execution_role = "arn:aws:iam::123456789:role/ecsTaskExecutionRole"
  service_launch_type         = "FARGATE"
  service_task_count          = 2

  # Variáveis de ambiente
  environment_variables = [
    {
      name  = "NODE_ENV"
      value = "production"
    },
    {
      name  = "PORT"
      value = "3000"
    }
  ]

  # Health check personalizado
  service_healthcheck = {
    healthy_threshold   = "2"
    unhealthy_threshold = "5"
    timeout             = "5"
    interval            = "30"
    matcher             = "200"
    path                = "/health"
  }
}
```

### Exemplo com múltiplos ambientes

```hcl
# Ambiente de desenvolvimento
module "api_dev" {
  source = "./ecs-service-module"

  region       = "us-east-1"
  service_name = "api"
  cluster_name = "dev-cluster"

  vpc_id          = var.vpc_id
  private_subnets = var.private_subnets

  service_port   = 3000
  service_cpu    = 256
  service_memory = 512

  service_listener = var.alb_listener_arn
  service_hosts    = ["api-dev.meudominio.com"]

  service_task_execution_role = var.task_execution_role
  service_task_count          = 1

  environment_variables = [
    {
      name  = "NODE_ENV"
      value = "development"
    }
  ]
}

# Ambiente de produção
module "api_prod" {
  source = "./ecs-service-module"

  region       = "us-east-1"
  service_name = "api"
  cluster_name = "prod-cluster"

  vpc_id          = var.vpc_id
  private_subnets = var.private_subnets

  service_port   = 3000
  service_cpu    = 512
  service_memory = 1024

  service_listener = var.alb_listener_arn
  service_hosts    = ["api.meudominio.com"]

  service_task_execution_role = var.task_execution_role
  service_task_count          = 3

  environment_variables = [
    {
      name  = "NODE_ENV"
      value = "production"
    }
  ]
}
```

## 📝 Variáveis

| Nome | Descrição | Tipo | Padrão | Obrigatório |
|------|-----------|------|--------|:-----------:|
| `region` | Região AWS onde os recursos serão implantados | `string` | - | ✅ |
| `service_name` | Nome do serviço ECS | `string` | - | ✅ |
| `cluster_name` | Nome do cluster ECS | `string` | - | ✅ |
| `vpc_id` | ID da VPC onde o serviço será implantado | `string` | - | ✅ |
| `private_subnets` | Lista de IDs das subnets privadas | `list(string)` | - | ✅ |
| `service_port` | Porta na qual o container expõe o serviço | `number` | - | ✅ |
| `service_cpu` | CPU alocada para o container (unidades de CPU) | `number` | - | ✅ |
| `service_memory` | Memória alocada para o container (MiB) | `number` | - | ✅ |
| `service_listener` | ARN do listener do ALB | `string` | - | ✅ |
| `service_task_execution_role` | ARN da role IAM para execução das tasks | `string` | - | ✅ |
| `service_hosts` | Lista de hostnames/domínios para roteamento | `list(string)` | - | ✅ |
| `service_launch_type` | Tipo de lançamento do serviço ECS | `string` | `"FARGATE"` | ❌ |
| `service_task_count` | Número desejado de tasks em execução | `number` | `1` | ❌ |
| `service_healthcheck` | Configurações de health check do ALB | `map(any)` | Ver abaixo | ❌ |
| `environment_variables` | Variáveis de ambiente para o container | `list(object)` | `[]` | ❌ |
| `capabilities` | Capacidades requeridas pelo serviço | `list(string)` | `["FARGATE"]` | ❌ |

### Configuração padrão do Health Check

```hcl
service_healthcheck = {
  healthy_threshold   = "3"
  unhealthy_threshold = "10"
  timeout             = "10"
  interval            = "10"
  matcher             = "200"
  path                = "/"
}
```

## 🔧 Recursos criados

### ECR Repository
- Nome: `{cluster_name}/{service_name}`
- Escaneamento de segurança habilitado
- Force delete habilitado (cuidado em produção)

### ECS Service
- Deployment com zero downtime (200% max, 100% min)
- Circuit breaker para rollback automático
- Integração com Application Load Balancer

### Security Group
- Entrada: Porta do serviço de qualquer lugar (0.0.0.0/0)
- Saída: Todo tráfego liberado
- **⚠️ Aviso**: Em produção, considere restringir as regras de entrada

### IAM Role
Permissões incluídas:
- Acesso ao ECR para baixar imagens
- Criação de logs no CloudWatch
- Registro/desregistro no Load Balancer
- Acesso ao Systems Manager Parameter Store
- Acesso ao AWS Secrets Manager

## 📊 Monitoramento

### CloudWatch Logs
- Grupo de logs: `{cluster_name}/{service_name}/logs`
- Stream prefix: `{service_name}`
- Logs ficam armazenados indefinidamente (configurável)

### Métricas ECS
O ECS automaticamente publica métricas no CloudWatch:
- CPU Utilization
- Memory Utilization
- Running Task Count
- Pending Task Count

## 🚀 Deploy da aplicação

### 1. Build e push da imagem

```bash
# Fazer login no ECR
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin {account-id}.dkr.ecr.us-east-1.amazonaws.com

# Build da imagem
docker build -t minha-app .

# Tag da imagem
docker tag minha-app:latest {account-id}.dkr.ecr.us-east-1.amazonaws.com/{cluster-name}/{service-name}:latest

# Push da imagem
docker push {account-id}.dkr.ecr.us-east-1.amazonaws.com/{cluster-name}/{service-name}:latest
```

### 2. Deploy do serviço

```bash
terraform plan
terraform apply
```

### 3. Forçar novo deployment (após atualizar imagem)

```bash
aws ecs update-service --cluster {cluster-name} --service {service-name} --force-new-deployment
```

## 🔒 Segurança

### Boas práticas implementadas:
- ✅ Tasks executam em subnets privadas
- ✅ Não atribuição de IP público
- ✅ Logs centralizados no CloudWatch
- ✅ Escaneamento de segurança nas imagens ECR
- ✅ IAM roles com princípio do menor privilégio

### Melhorias de segurança recomendadas:
- 🔧 Restringir Security Group para aceitar tráfego apenas do ALB
- 🔧 Implementar AWS WAF no ALB
- 🔧 Usar AWS Secrets Manager para dados sensíveis
- 🔧 Implementar tags de recursos para governança
- 🔧 Configurar retenção de logs no CloudWatch

## 📈 Escalabilidade

### Auto Scaling (opcional)
Para implementar auto scaling, adicione um recurso `aws_appautoscaling_target`:

```hcl
resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity       = 10
  min_capacity       = 2
  resource_id        = "service/${var.cluster_name}/${var.service_name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}
```

## 🐛 Troubleshooting

### Problemas comuns:

1. **Service não inicia**
   - Verificar logs no CloudWatch
   - Verificar se a imagem existe no ECR
   - Verificar recursos de CPU/memória

2. **Health check falhando**
   - Verificar se a aplicação responde na porta correta
   - Verificar path do health check
   - Verificar security group

3. **Não consegue acessar via ALB**
   - Verificar regras do listener
   - Verificar DNS do domínio
   - Verificar security groups do ALB

### Comandos úteis:

```bash
# Ver logs do serviço
aws logs tail {cluster-name}/{service-name}/logs --follow

# Descrever serviço
aws ecs describe-services --cluster {cluster-name} --services {service-name}

# Ver tasks em execução
aws ecs list-tasks --cluster {cluster-name} --service {service-name}

# Forçar nova deployment
aws ecs update-service --cluster {cluster-name} --service {service-name} --force-new-deployment
```

## 📚 Documentação adicional

- [Amazon ECS Documentation](https://docs.aws.amazon.com/ecs/)
- [AWS Fargate User Guide](https://docs.aws.amazon.com/AmazonECS/latest/userguide/what-is-fargate.html)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

## 🤝 Contribuição

Para contribuir com este módulo:

1. Fork o repositório
2. Crie uma branch para sua feature
3. Commit suas mudanças
4. Abra um Pull Request

## 📄 Licença

Este projeto está licenciado sob a MIT License - veja o arquivo [LICENSE](LICENSE) para detalhes.