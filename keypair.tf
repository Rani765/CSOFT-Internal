####################################################################
# Key Pairs
####################################################################

module "keypair_pritunl" {
  source = "./modules/key-pair"

  key_name           = var.ec2_pritunl_key_name
  create_private_key = true

  tags = {
    Name        = var.ec2_pritunl_key_name
    Environment = local.environment
  }
}

module "keypair_ocapp" {
  source = "./modules/key-pair"

  key_name           = var.ec2_ocapp_key_name
  create_private_key = true

  tags = {
    Name        = var.ec2_ocapp_key_name
    Environment = local.environment
  }
}

module "keypair_ocdb" {
  source = "./modules/key-pair"

  key_name           = var.ec2_ocdb_key_name
  create_private_key = true

  tags = {
    Name        = var.ec2_ocdb_key_name
    Environment = local.environment
  }
}

module "keypair_ecs_node" {
  source = "./modules/key-pair"

  key_name           = var.ecs_node_kp_name
  create_private_key = true

  tags = {
    Name        = var.ecs_node_kp_name
    Environment = local.environment
  }
}


####################################################################
# Store Private Keys in S3 Credentials Bucket
####################################################################

resource "aws_s3_object" "keypair_pritunl_pem" {
  bucket  = aws_s3_bucket.credential-bucket.bucket
  key     = "keypairs/${var.ec2_pritunl_key_name}.pem"
  content = module.keypair_pritunl.private_key_pem

  tags = {
    Name = var.ec2_pritunl_key_name
  }
}

resource "aws_s3_object" "keypair_ocapp_pem" {
  bucket  = aws_s3_bucket.credential-bucket.bucket
  key     = "keypairs/${var.ec2_ocapp_key_name}.pem"
  content = module.keypair_ocapp.private_key_pem

  tags = {
    Name = var.ec2_ocapp_key_name
  }
}

resource "aws_s3_object" "keypair_ocdb_pem" {
  bucket  = aws_s3_bucket.credential-bucket.bucket
  key     = "keypairs/${var.ec2_ocdb_key_name}.pem"
  content = module.keypair_ocdb.private_key_pem

  tags = {
    Name = var.ec2_ocdb_key_name
  }
}

resource "aws_s3_object" "keypair_ecs_node_pem" {
  bucket  = aws_s3_bucket.credential-bucket.bucket
  key     = "keypairs/${var.ecs_node_kp_name}.pem"
  content = module.keypair_ecs_node.private_key_pem

  tags = {
    Name = var.ecs_node_kp_name
  }
}

resource "aws_s3_object" "keypair_zookeeper_pem" {
  bucket  = aws_s3_bucket.credential-bucket.bucket
  key     = "keypairs/Csoft-Zookeeper-keypair.pem"
  content = module.keypair_zookeeper.private_key_pem

  tags = {
    Name = "Csoft-Zookeeper-keypair"
  }
}
