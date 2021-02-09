output "services_namespace_id" {
  description = "ID for the services namespace"  
  value = module.services_registry.namespace
}

output "desktops_namespace_id" {
  description = "ID for the desktops namespace"  
  value = module.desktops_registry.namespace
}

output "alb_sec_group" {
  description = "ID for the security group which protects the ALB"
  value = modules.alb.alb_sec_group
}

output "alb_listener_arn" {
  description = "ARN for the ALB listener which is created"
  value = modules.alb.listener_arn
}