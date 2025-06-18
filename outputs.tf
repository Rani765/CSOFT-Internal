########################################################################
# VPC
########################################################################
output "vpc_id" {
  value = module.vpc.vpc_id
}
output "vpc_cidr" {
  value = module.vpc.vpc_cidr_block
}
output "vpc_private_subnets" {
  value = module.vpc.private_subnets
}
output "vpc_public_subnets" {
  value = module.vpc.public_subnets
}
output "vpc_database_subnets" {
  value = module.vpc.database_subnets
}
output "vpc_public_route_table" {
  value = module.vpc.public_route_table_ids
}
output "vpc_private_route_table" {
  value = module.vpc.private_route_table_ids
}
output "vpc_az" {
  value = module.vpc.azs
}
########################################################################
# KMS
########################################################################
output "complete_key_arn" {
  description = "The Amazon Resource Name (ARN) of the key"
  value       = module.kms_complete.key_arn
}

output "complete_key_id" {
  description = "The globally unique identifier for the key"
  value       = module.kms_complete.key_id
}

output "complete_key_policy" {
  description = "The IAM resource policy set on the key"
  value       = module.kms_complete.key_policy
}

output "complete_external_key_expiration_model" {
  description = "Whether the key material expires. Empty when pending key material import, otherwise `KEY_MATERIAL_EXPIRES` or `KEY_MATERIAL_DOES_NOT_EXPIRE`"
  value       = module.kms_complete.external_key_expiration_model
}

output "complete_external_key_state" {
  description = "The state of the CMK"
  value       = module.kms_complete.external_key_state
}

output "complete_external_key_usage" {
  description = "The cryptographic operations for which you can use the CMK"
  value       = module.kms_complete.external_key_usage
}

output "complete_aliases" {
  description = "A map of aliases created and their attributes"
  value       = module.kms_complete.aliases
}

output "complete_grants" {
  description = "A map of grants created and their attributes"
  value       = module.kms_complete.grants
  sensitive   = true
}

# ################################################################################
# # Key Pair
# ################################################################################

# output "key_pair_id_pitunl" {
#   description = "The key pair ID"
#   value       = module.pritunl_key_pair.key_pair_id
# }

# output "key_pair_arn_pitunl" {
#   description = "The key pair ARN"
#   value       = module.pritunl_key_pair.key_pair_arn
# }

# output "key_pair_name_pitunl" {
#   description = "The key pair name"
#   value       = module.pritunl_key_pair.key_pair_name
# }

# output "key_pair_fingerprint_pitunl" {
#   description = "The MD5 public key fingerprint as specified in section 4 of RFC 4716"
#   value       = module.pritunl_key_pair.key_pair_fingerprint
# }

# output "private_key_id_pitunl" {
#   description = "Unique identifier for this resource: hexadecimal representation of the SHA1 checksum of the resource"
#   value       = module.pritunl_key_pair.private_key_id
# }

# output "private_key_openssh_pitunl" {
#   description = "Private key data in OpenSSH PEM (RFC 4716) format"
#   value       = module.pritunl_key_pair.private_key_openssh
#   sensitive   = true
# }

# output "private_key_pem_pitunl" {
#   description = "Private key data in PEM (RFC 1421) format"
#   value       = module.pritunl_key_pair.private_key_pem
#   sensitive   = true
# }

# output "public_key_fingerprint_md5_pitunl" {
#   description = "The fingerprint of the public key data in OpenSSH MD5 hash format, e.g. `aa:bb:cc:....` Only available if the selected private key format is compatible, similarly to `public_key_openssh` and the ECDSA P224 limitations"
#   value       = module.pritunl_key_pair.public_key_fingerprint_md5
# }

# output "public_key_fingerprint_sha256_pitunl" {
#   description = "The fingerprint of the public key data in OpenSSH SHA256 hash format, e.g. `SHA256:....` Only available if the selected private key format is compatible, similarly to `public_key_openssh` and the ECDSA P224 limitations"
#   value       = module.pritunl_key_pair.public_key_fingerprint_sha256
# }

# output "public_key_openssh_pitunl" {
#   description = "The public key data in \"Authorized Keys\" format. This is populated only if the configured private key is supported: this includes all `RSA` and `ED25519` keys"
#   value       = module.pritunl_key_pair.public_key_openssh
# }

# output "public_key_pem_pitunl" {
#   description = "Public key data in PEM (RFC 1421) format"
#   value       = module.pritunl_key_pair.public_key_pem
# }



# output "key_pair_id_ecs_node" {
#   description = "The key pair ID"
#   value       = module.ecs_node_key_pair.key_pair_id
# }

# output "key_pair_arn_ecs_node" {
#   description = "The key pair ARN"
#   value       = module.ecs_node_key_pair.key_pair_arn
# }

# output "key_pair_name_ecs_node" {
#   description = "The key pair name"
#   value       = module.ecs_node_key_pair.key_pair_name
# }

# output "key_pair_fingerprint_ecs_node" {
#   description = "The MD5 public key fingerprint as specified in section 4 of RFC 4716"
#   value       = module.ecs_node_key_pair.key_pair_fingerprint
# }

# output "private_key_id_ecs_node" {
#   description = "Unique identifier for this resource: hexadecimal representation of the SHA1 checksum of the resource"
#   value       = module.ecs_node_key_pair.private_key_id
# }

# output "private_key_openssh_ecs_node" {
#   description = "Private key data in OpenSSH PEM (RFC 4716) format"
#   value       = module.ecs_node_key_pair.private_key_openssh
#   sensitive   = true
# }

# output "private_key_pem_ecs_node" {
#   description = "Private key data in PEM (RFC 1421) format"
#   value       = module.ecs_node_key_pair.private_key_pem
#   sensitive   = true
# }

# output "public_key_fingerprint_md5_ecs_node" {
#   description = "The fingerprint of the public key data in OpenSSH MD5 hash format, e.g. `aa:bb:cc:....` Only available if the selected private key format is compatible, similarly to `public_key_openssh` and the ECDSA P224 limitations"
#   value       = module.ecs_node_key_pair.public_key_fingerprint_md5
# }

# output "public_key_fingerprint_sha256_ecs_node" {
#   description = "The fingerprint of the public key data in OpenSSH SHA256 hash format, e.g. `SHA256:....` Only available if the selected private key format is compatible, similarly to `public_key_openssh` and the ECDSA P224 limitations"
#   value       = module.ecs_node_key_pair.public_key_fingerprint_sha256
# }

# output "public_key_openssh_ecs_node" {
#   description = "The public key data in \"Authorized Keys\" format. This is populated only if the configured private key is supported: this includes all `RSA` and `ED25519` keys"
#   value       = module.ecs_node_key_pair.public_key_openssh
# }

# output "public_key_pem_ecs_node" {
#   description = "Public key data in PEM (RFC 1421) format"
#   value       = module.ecs_node_key_pair.public_key_pem
# }