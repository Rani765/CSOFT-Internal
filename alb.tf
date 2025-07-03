
module "alb-pvt-securtiy-group" {
  source      = "./modules/sg"
  name        = "Csoft-prod-pvt-alb-sg"
  description = "alb-global Security group"
  vpc_id      = local.alb_vpc_id

  ingress_rules = local.alb_global_ingress_rules
  egress_rules  = local.alb_global_egress_rules
}
module "alb" {
  source = "./modules/loadbalancer_module"

  name = local.alb_name

  load_balancer_type = "application"
  internal           = true
  vpc_id             = module.vpc.vpc_id
  subnets            = [element(module.vpc.private_subnets, 0), element(module.vpc.private_subnets, 1)]

  # For example only
  enable_deletion_protection = false

  # Security Group
  security_groups = [module.alb-pvt-securtiy-group.security_group_id]

  listeners = {
    http = {
      port     = 81
      protocol = "HTTP"
      #   redirect = {
      #     port        = "443"
      #     protocol    = "HTTPS"
      #     status_code = "HTTP_301"
      #   }
      fixed_response = {
        content_type = "text/plain",
        message_body = "Request Correct URL",
        status_code  = "404"
      }
      # forward = {
      #   target_group_key = "app_ecs"
      # }
    }
    # https = {
    #   port            = 443
    #   protocol        = "HTTPS"
    #   ssl_policy      = "ELBSecurityPolicy-TLS13-1-2-Res-2021-06"
    #   certificate_arn = module.acm_main.acm_certificate_arn
    #   #additional_certificate_arns = [module.wildcard_cert.acm_certificate_arn]
    #   forward = {
    #     target_group_key = "app_ecs"
    #   }
    # #   fixed_response = {
    # #     content_type = "text/plain",
    # #     message_body = "Request Correct URL",
    # #     status_code  = "404"
    # #   }
    #   rules = {
    #     back_revmigrate_com = {
    #       priority = 1
    #       actions = [
    #         {
    #           type             = "forward"
    #           target_group_key = "app_ecs"
    #         }
    #       ]
    #       conditions = [{ host_header = { values = ["back.revmigrate.com"] } }]
    #     }
    #   }
    # }
  }

  target_groups = {
    solr_ecs = {
      backend_protocol                  = "HTTP"
      backend_port                      = "8983"
      name                              = "csoft-prod-solr-tg"
      target_type                       = "ip"
      deregistration_delay              = 5
      load_balancing_cross_zone_enabled = true

      health_check = {
        enabled             = true
        healthy_threshold   = 5
        interval            = 30
        matcher             = "200"
        path                = "/solr/"
        port                = "traffic-port"
        protocol            = "HTTP"
        timeout             = 5
        unhealthy_threshold = 2
      }

      # Theres nothing to attach here in this definition. Instead,
      # ECS will attach the IPs of the tasks to this target group
      create_attachment = false
    }
    tika_ecs = {
      backend_protocol                  = "HTTP"
      backend_port                      = "80"
      name                              = "csoft-prod-tika-tgs"
      target_type                       = "instance"
      deregistration_delay              = 5
      load_balancing_cross_zone_enabled = true

      health_check = {
        enabled             = true
        healthy_threshold   = 5
        interval            = 30
        matcher             = "200"
        path                = "/"
        port                = "traffic-port"
        protocol            = "HTTP"
        timeout             = 5
        unhealthy_threshold = 2
      }

      # Theres nothing to attach here in this definition. Instead,
      # ECS will attach the IPs of the tasks to this target group
      create_attachment = false
    }
    wi_api_ecs = {
      backend_protocol                  = "HTTP"
      backend_port                      = "80"
      name                              = "csoft-prod-wi-api-tg"
      target_type                       = "instance"
      deregistration_delay              = 5
      load_balancing_cross_zone_enabled = true

      health_check = {
        enabled             = true
        healthy_threshold   = 5
        interval            = 30
        matcher             = "200"
        path                = "/"
        port                = "traffic-port"
        protocol            = "HTTP"
        timeout             = 5
        unhealthy_threshold = 2
      }

      # Theres nothing to attach here in this definition. Instead,
      # ECS will attach the IPs of the tasks to this target group
      create_attachment = false
    }
    jobsrv_ecs = {
      backend_protocol                  = "HTTP"
      backend_port                      = "80"
      name                              = "csoft-prod-jobservice-tg"
      target_type                       = "instance"
      deregistration_delay              = 5
      load_balancing_cross_zone_enabled = true

      health_check = {
        enabled             = true
        healthy_threshold   = 5
        interval            = 30
        matcher             = "200"
        path                = "/"
        port                = "traffic-port"
        protocol            = "HTTP"
        timeout             = 5
        unhealthy_threshold = 2
      }

      # Theres nothing to attach here in this definition. Instead,
      # ECS will attach the IPs of the tasks to this target group
      create_attachment = false
    }
    identity_ecs = {
      backend_protocol                  = "HTTP"
      backend_port                      = "80"
      name                              = "csoft-prod-identity-service-tg"
      target_type                       = "instance"
      deregistration_delay              = 5
      load_balancing_cross_zone_enabled = true

      health_check = {
        enabled             = true
        healthy_threshold   = 5
        interval            = 30
        matcher             = "200"
        path                = "/"
        port                = "traffic-port"
        protocol            = "HTTP"
        timeout             = 5
        unhealthy_threshold = 2
      }

      # Theres nothing to attach here in this definition. Instead,
      # ECS will attach the IPs of the tasks to this target group
      create_attachment = false
    }
  }
  tags = local.alb_tags
}


###############################################
# Public ALB
###############################################
module "alb-pub-securtiy-group" {
  source      = "./modules/sg"
  name        = "Csoft-prod-public-alb-sg"
  description = "alb-global Security group"
  vpc_id      = local.alb_vpc_id

  ingress_rules = local.alb_global_ingress_rules
  egress_rules  = local.alb_global_egress_rules
}
module "alb-pub" {
  source = "./modules/loadbalancer_module"

  name = local.alb_name_pub

  load_balancer_type = "application"
  internal           = false
  vpc_id             = module.vpc.vpc_id
  subnets            = [element(module.vpc.public_subnets, 0), element(module.vpc.public_subnets, 1)]

  # For example only
  enable_deletion_protection = false

  # Security Group
  security_groups = [module.alb-pub-securtiy-group.security_group_id]

  listeners = {
    http = {
      port     = 80
      protocol = "HTTP"
      #   redirect = {
      #     port        = "443"
      #     protocol    = "HTTPS"
      #     status_code = "HTTP_301"
      #   }
      fixed_response = {
        content_type = "text/plain",
        message_body = "Request Correct URL",
        status_code  = "404"
      }
      # forward = {
      #   target_group_key = "app_ecs"
      # }
    }
    # https = {
    #   port            = 443
    #   protocol        = "HTTPS"
    #   ssl_policy      = "ELBSecurityPolicy-TLS13-1-2-Res-2021-06"
    #   certificate_arn = module.acm_main.acm_certificate_arn
    #   #additional_certificate_arns = [module.wildcard_cert.acm_certificate_arn]
    #   forward = {
    #     target_group_key = "app_ecs"
    #   }
    # #   fixed_response = {
    # #     content_type = "text/plain",
    # #     message_body = "Request Correct URL",
    # #     status_code  = "404"
    # #   }
    #   rules = {
    #     back_revmigrate_com = {
    #       priority = 1
    #       actions = [
    #         {
    #           type             = "forward"
    #           target_group_key = "app_ecs"
    #         }
    #       ]
    #       conditions = [{ host_header = { values = ["back.revmigrate.com"] } }]
    #     }
    #   }
    # }
  }

  target_groups = {
    oc_app = {
      backend_protocol                  = "HTTP"
      backend_port                      = "80"
      name                              = "csoft-prod-oc-app-tg"
      target_type                       = "instance"
      deregistration_delay              = 5
      load_balancing_cross_zone_enabled = true

      health_check = {
        enabled             = true
        healthy_threshold   = 5
        interval            = 30
        matcher             = "200"
        path                = "/"
        port                = "traffic-port"
        protocol            = "HTTP"
        timeout             = 5
        unhealthy_threshold = 2
      }

      # Theres nothing to attach here in this definition. Instead,
      # ECS will attach the IPs of the tasks to this target group
      create_attachment = false
    }
  }
  tags = local.alb_tags
}