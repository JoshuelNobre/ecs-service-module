resource "aws_service_discovery_service" "main" {

  count = var.service_discovery_namespace != null ? 1 : 0
  name  = var.service_name

  dns_config {
    namespace_id = var.service_discovery_namespace
    dns_records {
      type = "A"
      ttl  = 10
    }
    routing_policy = "MULTIVALUE"
  }
}