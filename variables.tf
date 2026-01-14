variable "region" {}

variable "service_name" {}

variable "container_image" {}

variable "cluster_name" {}

variable "vpc_id" {}

variable "private_subnets" {}

variable "service_port" {}

variable "service_cpu" {}

variable "service_memory" {}

variable "service_listener" {}

variable "service_task_execution_role" {}

variable "service_launch_type" {
  type = list(object({
    capacity_provider = string
    weight            = number
  }))
  default = [
    {
      capacity_provider = "FARGATE_SPOT"
      weight            = 100
    }
  ]
}

variable "service_task_count" {}

variable "service_hosts" {}

variable "service_healthcheck" {
  type = map(any)
}

variable "environment_variables" {
  type = list(object({
    name  = string
    value = string
  }))
}

variable "secrets" {
  type = list(object({
    name      = string
    valueFrom = string
  }))
  description = "Lista de secrets do parameter store ou do secrets manager"
  default     = []
}

variable "capabilities" {
  type        = list(string)
  default     = []
  description = "Lista de capacidades, como EC2 ou FARGATE"
}

variable "scale_type" {
  default = null
}

variable "task_minimum" {
  default = 2
}

variable "task_maximum" {
  default = 10
}

### Autoscaling de CPU

variable "scale_out_cpu_threshold" {
  default = 80
}

variable "scale_out_adjustment" {
  default = 1
}

variable "scale_out_comparison_operator" {
  default = "GreaterThanOrEqualToThreshold"
}

variable "scale_out_statistic" {
  default = "Average"
}

variable "scale_out_period" {
  default = 60
}

variable "scale_out_evaluation_periods" {
  default = 2
}

variable "scale_out_cooldown" {
  default = 60
}

variable "scale_in_cpu_threshold" {
  default = 30
}

variable "scale_in_adjustment" {
  default = -1
}

variable "scale_in_comparison_operator" {
  default = "LessThanOrEqualToThreshold"
}

variable "scale_in_statistic" {
  default = "Average"
}

variable "scale_in_period" {
  default = 120
}

variable "scale_in_evaluation_periods" {
  default = 3
}

variable "scale_in_cooldown" {
  default = 120
}

# Tracking CPU
variable "scale_tracking_cpu" {
  default = 80
}

# ECR Configuration
variable "use_existing_ecr" {
  description = "Se true, usa um repositório ECR existente em vez de criar um novo"
  type        = bool
  default     = false
}

variable "alb_arn" {
  default = ""
}

variable "scale_tracking_requests" {
  default = 0
}

variable "efs_volumes" {
  type = list(object({
    volume_name      = string
    file_system_id   = string
    file_system_root = string
    mount_point      = string
    read_only        = bool
  }))
  default = []
}

variable "service_discovery_namespace" {
  default = null
}