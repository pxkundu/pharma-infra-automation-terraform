locals {
  name = "${var.project_name}-${var.environment}"
}

# GuardDuty Detector
resource "aws_guardduty_detector" "main" {
  enable = true

  datasources {
    s3_logs {
      enable = true
    }
    kubernetes {
      audit_logs {
        enable = true
      }
    }
    malware_protection {
      scan_ec2_instance_with_findings {
        ebs_volumes {
          enable = true
        }
      }
    }
  }

  finding_publishing_frequency = "FIFTEEN_MINUTES"

  tags = merge(
    var.tags,
    {
      Name = "${local.name}-guardduty"
    }
  )
}

# GuardDuty Filter
resource "aws_guardduty_filter" "high_severity" {
  name        = "${local.name}-high-severity"
  action      = "ARCHIVE"
  detector_id = aws_guardduty_detector.main.id
  rank        = 1

  finding_criteria {
    criterion {
      field  = "severity"
      equals = ["HIGH"]
    }
  }
}

# GuardDuty Threat Intel Set
resource "aws_guardduty_threatintelset" "known_bad_ips" {
  name        = "${local.name}-known-bad-ips"
  detector_id = aws_guardduty_detector.main.id
  format      = "TXT"
  location    = "https://s3.amazonaws.com/${var.threat_intel_bucket}/${var.threat_intel_key}"
  activate    = true
}

# GuardDuty IPSet
resource "aws_guardduty_ipset" "trusted_ips" {
  name        = "${local.name}-trusted-ips"
  detector_id = aws_guardduty_detector.main.id
  format      = "TXT"
  location    = "https://s3.amazonaws.com/${var.trusted_ips_bucket}/${var.trusted_ips_key}"
  activate    = true
}

# CloudWatch Event Rule for GuardDuty findings
resource "aws_cloudwatch_event_rule" "guardduty_findings" {
  name        = "${local.name}-guardduty-findings"
  description = "Capture GuardDuty findings"

  event_pattern = jsonencode({
    source      = ["aws.guardduty"]
    detail-type = ["GuardDuty Finding"]
  })

  tags = var.tags
}

# CloudWatch Event Target for GuardDuty findings
resource "aws_cloudwatch_event_target" "guardduty_findings" {
  rule      = aws_cloudwatch_event_rule.guardduty_findings.name
  target_id = "${local.name}-guardduty-findings"
  arn       = var.sns_topic_arn
}

# IAM role for GuardDuty to publish to SNS
resource "aws_iam_role" "guardduty_sns" {
  name = "${local.name}-guardduty-sns-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "events.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

# IAM policy for GuardDuty to publish to SNS
resource "aws_iam_role_policy" "guardduty_sns" {
  name = "${local.name}-guardduty-sns-policy"
  role = aws_iam_role.guardduty_sns.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sns:Publish"
        ]
        Resource = var.sns_topic_arn
      }
    ]
  })
} 