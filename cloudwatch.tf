resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "devops-test-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric"
        x = 0
        y = 0
        width = 6
        height = 6
        properties = {
          metrics = [
            [ "AWS/ECS", "CPUUtilization", "ClusterName", aws_ecs_cluster.this.name ]
          ]
          title = "ECS Cluster CPU Utilization"
          stat  = "Average",
          "region": "eu-north-1",
          "annotations": {}
        }
      },
      {
        type = "metric"
        x = 6
        y = 0
        width = 6
        height = 6
        properties = {
          metrics = [
            [ "AWS/ECS", "MemoryUtilization", "ClusterName", aws_ecs_cluster.this.name ]
          ]
          title = "ECS Cluster Memory Utilization"
          stat  = "Average",
          "region": "eu-north-1",
          "annotations": {}
        }
      },
      {
        type = "metric"
        x = 0
        y = 6
        width = 6
        height = 6
        properties = {
          metrics = [
            [ "AWS/ApplicationELB", "TargetResponseTime", "LoadBalancer", aws_lb.app.arn_suffix ]
          ]
          title = "ALB Target Response Time"
          stat  = "Average"
          "region": "eu-north-1",
          "annotations": {}
        }
      },
      {
        type = "metric"
        x = 6
        y = 6
        width = 6
        height = 6
        properties = {
          metrics = [
            [ "AWS/ApplicationELB", "HTTPCode_Target_4XX_Count", "LoadBalancer", aws_lb.app.arn_suffix ],
            [ ".", "HTTPCode_Target_5XX_Count", ".", "." ]
          ]
          title = "ALB 4xx & 5xx Errors"
          stat  = "Sum",
          "region": "eu-north-1",
          "annotations": {}
        }
      },
      {
        type = "metric"
        x = 0
        y = 12
        width = 6
        height = 6
        properties = {
          metrics = [
            [ "AWS/ApplicationELB", "ActiveConnectionCount", "LoadBalancer", aws_lb.app.arn_suffix ]
          ]
          title = "ALB Active Connection Count"
          stat  = "Average",
          "region": "eu-north-1",
          "annotations": {}
        }
      },
      {
        type = "metric"
        x = 6
        y = 12
        width = 6
        height = 6
        properties = {
          metrics = [
            [ "AWS/RDS", "FreeStorageSpace", "DBInstanceIdentifier", aws_db_instance.devops-test-db.id ]
          ]
          title = "RDS Free Storage Space"
          stat  = "Average"
          "region": "eu-north-1",
          "annotations": {}
        }
      },
      {
        "type": "metric",
        "x": 0,
        "y": 18,
        "width": 6,
        "height": 6,
        "properties": {
          "metrics": [
            [ "AWS/RDS", "CPUUtilization", "DBInstanceIdentifier", "${aws_db_instance.devops-test-db.id}" ]
          ],
          "title": "RDS CPU Utilization",
          "stat": "Average",
          "region": "eu-north-1",
          "annotations": {}
        }
    }
    ]
  })
}

resource "aws_cloudwatch_metric_alarm" "alb_5xx_rate" {
  alarm_name          = "ALB-5xx-Error-Rate-High"
  alarm_description   = "Triggers if ALB 5xx error rate exceeds 5% over 10 minutes"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  threshold           = 5
  datapoints_to_alarm = 1
  treat_missing_data  = "notBreaching"

  metric_query {
    id          = "e1"
    expression  = "100 * m1 / m2"
    label       = "5xx Error Rate (%)"
    return_data = true
  }

  metric_query {
    id = "m1"
    metric {
      namespace  = "AWS/ApplicationELB"
      metric_name = "HTTPCode_Target_5XX_Count"
      dimensions = {
        LoadBalancer = aws_lb.app.arn_suffix
      }
      period = 600
      stat   = "Sum"
    }
    return_data = false
  }

  metric_query {
    id = "m2"
    metric {
      namespace  = "AWS/ApplicationELB"
      metric_name = "RequestCount"
      dimensions = {
        LoadBalancer = aws_lb.app.arn_suffix
      }
      period = 600
      stat   = "Sum"
    }
    return_data = false
  }

  alarm_actions = [aws_sns_topic.alarm_topic.arn]
  ok_actions    = [aws_sns_topic.alarm_topic.arn]
}
