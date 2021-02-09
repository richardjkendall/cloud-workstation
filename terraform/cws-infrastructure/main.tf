module "fargate_cluster" {
  source = "../modules/fargate"

  aws_region   = var.aws_region
  cluster_name = var.cluster_name
}

module "services_registry" {
  source = "../modules/service-registry"

  aws_region = var.aws_region
  dns_id     = "services.${var.namespace_suffix}"
}

module "desktops_registry" {
  source = "../modules/service-registry"

  aws_region = var.aws_region
  dns_id     = "desktops.${var.namespace_suffix}"
}

module "alb" {
  source = "../modules/simple-alb"

  aws_region  = var.aws_region
  root_domain = var.root_domain
  hostname    = var.hostname
  subnets     = var.pub_subnets
}