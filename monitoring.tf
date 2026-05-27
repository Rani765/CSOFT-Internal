####################################################################
# CloudWatch Monitoring - EC2 Instances
####################################################################

locals {
  # List of instance IDs to monitor with manual OS specification
  instance_configs = {
    "${module.ec2_ocapp.id}"        = "windows"
    "${module.ec2_ocdb.id}"         = "windows"
    "${module.ec2_pritunl.id}"      = "linux"
    "${module.ec2_jenkins.id}"      = "linux"
    "${module.ec2_zookeeper[0].id}" = "linux"
    "${module.ec2_zookeeper[1].id}" = "linux"
    "${module.ec2_zookeeper[2].id}" = "linux"
  }

  instance_ids = keys(local.instance_configs)
}

data "aws_instance" "instances" {
  for_each    = toset(local.instance_ids)
  instance_id = each.key
}

locals {
  # Build instance details with manual OS
  instance_details = [
    for id in local.instance_ids : {
      id   = id
      name = data.aws_instance.instances[id].tags["Name"]
      os   = local.instance_configs[id]
    }
  ]

  # Disk configurations per instance
  instance_disk_configs = {
    "${module.ec2_ocapp.id}" = [
      { path = "C:", threshold_85 = 15, threshold_95 = 5 },
      { path = "D:", threshold_85 = 15, threshold_95 = 5 }
    ]
    "${module.ec2_ocdb.id}" = [
      { path = "C:", threshold_85 = 15, threshold_95 = 5 },
      { path = "D:", threshold_85 = 15, threshold_95 = 5 }
    ]
    "${module.ec2_pritunl.id}" = [
      { path = "/", device = "nvme0n1p1", fstype = "xfs", threshold_85 = 85, threshold_95 = 95 }
    ]
    "${module.ec2_jenkins.id}" = [
      { path = "/", device = "nvme0n1p1", fstype = "ext4", threshold_85 = 85, threshold_95 = 95 }
    ]
    "${module.ec2_zookeeper[0].id}" = [
      { path = "/", device = "nvme0n1p1", fstype = "ext4", threshold_85 = 85, threshold_95 = 95 }
    ]
    "${module.ec2_zookeeper[1].id}" = [
      { path = "/", device = "nvme0n1p1", fstype = "ext4", threshold_85 = 85, threshold_95 = 95 }
    ]
    "${module.ec2_zookeeper[2].id}" = [
      { path = "/", device = "nvme0n1p1", fstype = "ext4", threshold_85 = 85, threshold_95 = 95 }
    ]
  }

  # Flatten disk alarms
  disk_alarms = flatten([
    for instance in local.instance_details : [
      for disk in lookup(local.instance_disk_configs, instance.id, []) : {
        key           = "${instance.id}-${disk.path}"
        instance_id   = instance.id
        instance_name = instance.name
        os            = instance.os
        path          = disk.path
        device        = lookup(disk, "device", null)
        fstype        = lookup(disk, "fstype", null)
        threshold_85  = disk.threshold_85
        threshold_95  = disk.threshold_95
      }
    ]
  ])
}

####################################################################
# SNS Topic
####################################################################

data "aws_sns_topic" "sns_topic" {
  name = "CSoft-Prod-SNS"
}

####################################################################
# CPU Alarms
####################################################################

resource "aws_cloudwatch_metric_alarm" "cpu_85" {
  for_each = { for instance in local.instance_details : instance.id => instance }

  alarm_name          = "${each.value.name}-CPU-85%-#ALARM"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Maximum"
  threshold           = 85

  dimensions = {
    InstanceId = each.value.id
  }

  alarm_actions = [data.aws_sns_topic.sns_topic.arn]
}

resource "aws_cloudwatch_metric_alarm" "cpu_95" {
  for_each = { for instance in local.instance_details : instance.id => instance }

  alarm_name          = "${each.value.name}-CPU-95%-#ALARM"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Maximum"
  threshold           = 95

  dimensions = {
    InstanceId = each.value.id
  }

  alarm_actions = [data.aws_sns_topic.sns_topic.arn]
}

####################################################################
# Status Check Alarms
####################################################################

resource "aws_cloudwatch_metric_alarm" "status_system" {
  for_each = { for instance in local.instance_details : instance.id => instance }

  alarm_name          = "${each.value.name}-StatusCheckFailed_System-#ALARM"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "StatusCheckFailed_System"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Maximum"
  threshold           = 1

  dimensions = {
    InstanceId = each.value.id
  }

  alarm_actions = [
    "arn:aws:automate:${var.region_backend}:ec2:recover",
    data.aws_sns_topic.sns_topic.arn
  ]
}

resource "aws_cloudwatch_metric_alarm" "status_instance" {
  for_each = { for instance in local.instance_details : instance.id => instance }

  alarm_name          = "${each.value.name}-StatusCheckFailed_Instance-#ALARM"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "StatusCheckFailed_Instance"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Maximum"
  threshold           = 1

  dimensions = {
    InstanceId = each.value.id
  }

  alarm_actions = [
    "arn:aws:automate:${var.region_backend}:ec2:reboot",
    data.aws_sns_topic.sns_topic.arn
  ]
}

resource "aws_cloudwatch_metric_alarm" "status_ebs" {
  for_each = { for instance in local.instance_details : instance.id => instance }

  alarm_name          = "${each.value.name}-StatusCheckFailed_AttachedEBS-#ALARM"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "StatusCheckFailed_AttachedEBS"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Maximum"
  threshold           = 1

  dimensions = {
    InstanceId = each.value.id
  }

  alarm_actions = [
    "arn:aws:automate:${var.region_backend}:ec2:reboot",
    data.aws_sns_topic.sns_topic.arn
  ]
}

####################################################################
# Memory Alarms
####################################################################

resource "aws_cloudwatch_metric_alarm" "mem_85" {
  for_each = { for instance in local.instance_details : instance.id => instance }

  alarm_name          = "${each.value.name}-Memory-85%-#ALARM"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = each.value.os == "windows" ? "Memory % Committed Bytes In Use" : "mem_used_percent"
  namespace           = "CWAgent"
  period              = 60
  statistic           = "Maximum"
  threshold           = 85

  dimensions = each.value.os == "windows" ? {
    InstanceId = each.value.id
    objectname = "Memory"
  } : {
    InstanceId = each.value.id
  }

  alarm_actions = [data.aws_sns_topic.sns_topic.arn]
}

resource "aws_cloudwatch_metric_alarm" "mem_95" {
  for_each = { for instance in local.instance_details : instance.id => instance }

  alarm_name          = "${each.value.name}-Memory-95%-#ALARM"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = each.value.os == "windows" ? "Memory % Committed Bytes In Use" : "mem_used_percent"
  namespace           = "CWAgent"
  period              = 60
  statistic           = "Maximum"
  threshold           = 95

  dimensions = each.value.os == "windows" ? {
    InstanceId = each.value.id
    objectname = "Memory"
  } : {
    InstanceId = each.value.id
  }

  alarm_actions = [data.aws_sns_topic.sns_topic.arn]
}

####################################################################
# Disk Alarms - 85%
####################################################################

resource "aws_cloudwatch_metric_alarm" "disk_85" {
  for_each = { for alarm in local.disk_alarms : "${alarm.key}-85" => alarm }

  alarm_name          = "${each.value.instance_name}-Disk(${each.value.path})-85%-#ALARM"
  comparison_operator = each.value.os == "windows" ? "LessThanOrEqualToThreshold" : "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = each.value.os == "windows" ? "LogicalDisk % Free Space" : "disk_used_percent"
  namespace           = "CWAgent"
  period              = 60
  statistic           = "Maximum"
  threshold           = each.value.threshold_85

  dimensions = each.value.os == "windows" ? {
    InstanceId = each.value.instance_id
    objectname = "LogicalDisk"
    instance   = each.value.path
  } : {
    InstanceId = each.value.instance_id
    path       = each.value.path
    device     = each.value.device
    fstype     = each.value.fstype
  }

  alarm_actions = [data.aws_sns_topic.sns_topic.arn]
}

####################################################################
# Disk Alarms - 95%
####################################################################

resource "aws_cloudwatch_metric_alarm" "disk_95" {
  for_each = { for alarm in local.disk_alarms : "${alarm.key}-95" => alarm }

  alarm_name          = "${each.value.instance_name}-Disk(${each.value.path})-95%-#ALARM"
  comparison_operator = each.value.os == "windows" ? "LessThanOrEqualToThreshold" : "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = each.value.os == "windows" ? "LogicalDisk % Free Space" : "disk_used_percent"
  namespace           = "CWAgent"
  period              = 60
  statistic           = "Maximum"
  threshold           = each.value.threshold_95

  dimensions = each.value.os == "windows" ? {
    InstanceId = each.value.instance_id
    objectname = "LogicalDisk"
    instance   = each.value.path
  } : {
    InstanceId = each.value.instance_id
    path       = each.value.path
    device     = each.value.device
    fstype     = each.value.fstype
  }

  alarm_actions = [data.aws_sns_topic.sns_topic.arn]
}
