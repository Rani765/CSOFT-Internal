####################################################################
# SSM Patch Management
####################################################################

locals {
  patch_os_catalog = {
    linux = {
      baseline_name         = "CSoft-AL2023-Patch-Baseline"
      operating_system      = "AMAZON_LINUX_2023"
      description           = "CSoft patch baseline for Amazon Linux 2023"
      product_key           = "PRODUCT"
      product_values        = ["AmazonLinux2023"]
      classification_key    = "CLASSIFICATION"
      classification_values = ["Security", "Bugfix", "Enhancement", "Recommended", "Newpackage"]
      severity_key          = "SEVERITY"
      severity_values       = ["Critical", "Important", "Medium", "Low", "None"]
    }
    ubuntu = {
      baseline_name         = "CSoft-Ubuntu-Patch-Baseline"
      operating_system      = "UBUNTU"
      description           = "CSoft patch baseline for Ubuntu 24.04"
      product_key           = "PRODUCT"
      product_values        = ["Ubuntu24.04"]
      classification_key    = "SECTION"
      classification_values = ["All", "libs", "libdevel", "doc", "debug", "translations", "devel", "admin", "oldlibs", "label", "utils", "net", "web", "gnome", "perl", "cli-mono", "universe/net", "x11", "universe/utils", "universe/python"]
      severity_key          = "PRIORITY"
      severity_values       = ["Required", "Important", "Standard", "Optional", "Extra"]
    }
    windows = {
      baseline_name         = "CSoft-Windows-2022-Patch-Baseline"
      operating_system      = "WINDOWS"
      description           = "CSoft patch baseline for Windows Server 2022"
      product_key           = "PRODUCT"
      product_values        = ["WindowsServer2022"]
      classification_key    = "CLASSIFICATION"
      classification_values = ["SecurityUpdates", "CriticalUpdates", "Updates", "UpdateRollups"]
      severity_key          = "MSRC_SEVERITY"
      severity_values       = ["Critical", "Important", "Moderate", "Low"]
    }
  }

  # Map instances to their OS patch group
  patch_managed_instances = {
    pritunl = {
      instance_id = module.ec2_pritunl.id
      name        = local.ec2_pritunl_name
      os_key      = "linux"
    }
    jenkins = {
      instance_id = module.ec2_jenkins.id
      name        = "CSoft-${local.environment}-Jenkins"
      os_key      = "ubuntu"
    }
    zookeeper-1 = {
      instance_id = module.ec2_zookeeper[0].id
      name        = "CSoft-${local.environment}-Zookeeper-1"
      os_key      = "ubuntu"
    }
    zookeeper-2 = {
      instance_id = module.ec2_zookeeper[1].id
      name        = "CSoft-${local.environment}-Zookeeper-2"
      os_key      = "ubuntu"
    }
    zookeeper-3 = {
      instance_id = module.ec2_zookeeper[2].id
      name        = "CSoft-${local.environment}-Zookeeper-3"
      os_key      = "ubuntu"
    }
    ocapp = {
      instance_id = module.ec2_ocapp.id
      name        = local.ec2_ocapp_name
      os_key      = "windows"
    }
    ocdb = {
      instance_id = module.ec2_ocdb.id
      name        = local.ec2_ocdb_name
      os_key      = "windows"
    }
  }

  # Group instance IDs by OS
  patch_os_groups = {
    for os_key in distinct([for instance in values(local.patch_managed_instances) : instance.os_key]) :
    os_key => [for instance in values(local.patch_managed_instances) : instance.instance_id if instance.os_key == os_key]
  }
}

####################################################################
# Wait for instances to be ready
####################################################################

resource "time_sleep" "wait_30_minutes_after_launch" {
  create_duration = "1m"

  depends_on = [
    module.ec2_pritunl,
    module.ec2_jenkins,
    module.ec2_zookeeper,
    module.ec2_ocapp,
    module.ec2_ocdb
  ]
}

####################################################################
# Patch Baselines
####################################################################

resource "aws_ssm_patch_baseline" "custom" {
  for_each = {
    for os_key, config in local.patch_os_catalog :
    os_key => config
    if contains(keys(local.patch_os_groups), os_key)
  }

  name             = each.value.baseline_name
  operating_system = each.value.operating_system
  description      = each.value.description

  approval_rule {
    approve_after_days = 0

    patch_filter {
      key    = each.value.product_key
      values = each.value.product_values
    }

    patch_filter {
      key    = each.value.classification_key
      values = each.value.classification_values
    }

    patch_filter {
      key    = each.value.severity_key
      values = each.value.severity_values
    }
  }

  approved_patches_compliance_level    = "UNSPECIFIED"
  approved_patches_enable_non_security = each.value.operating_system != "WINDOWS" ? true : false
}

####################################################################
# Set as Default Patch Baseline
####################################################################

resource "aws_ssm_default_patch_baseline" "default" {
  for_each = aws_ssm_patch_baseline.custom

  baseline_id      = each.value.id
  operating_system = each.value.operating_system
}

####################################################################
# Run Patch on Instances (grouped by OS)
####################################################################

resource "aws_ssm_association" "patch_instances" {
  for_each = local.patch_os_groups

  name = "AWS-RunPatchBaseline"

  targets {
    key    = "InstanceIds"
    values = each.value
  }

  parameters = {
    Operation        = "Install"
    BaselineOverride = ""
  }

  depends_on = [
    aws_ssm_default_patch_baseline.default,
    time_sleep.wait_30_minutes_after_launch
  ]
}
