resource "aws_sns_topic" "alarm_topic" {
  name = "egdevtest-alb-errors"
}
