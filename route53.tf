####################################################################
# Route53 - Private Hosted Zone
####################################################################

module "route53_zone" {
  source = "./modules/route53_module/zones"

  create = true

  zones = {
    "csoft.internal" = {
      domain_name = "csoft.internal"
      comment     = "CSoft Production Private Hosted Zone"
      vpc = {
        vpc_id = module.vpc.vpc_id
      }
      tags = {
        Environment = local.environment
        Name        = "csoft-prod-private-zone"
      }
    }
  }

  tags = {
    Environment = local.environment
  }
}

####################################################################
# Route53 - Zookeeper DNS Records
####################################################################

module "route53_zookeeper_records" {
  source = "./modules/route53_module/records"

  create       = true
  zone_id      = module.route53_zone.route53_zone_zone_id["csoft.internal"]
  private_zone = true

  depends_on = [module.route53_zone, module.ec2_zookeeper]

  records = [
    {
      name    = "zk1"
      type    = "A"
      ttl     = 300
      records = [module.ec2_zookeeper[0].private_ip]
    },
    {
      name    = "zk2"
      type    = "A"
      ttl     = 300
      records = [module.ec2_zookeeper[1].private_ip]
    },
    {
      name    = "zk3"
      type    = "A"
      ttl     = 300
      records = [module.ec2_zookeeper[2].private_ip]
    }
  ]
}
