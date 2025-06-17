resource "aws_cloudwatch_dashboard" "dt_s3_log_forwarder_monitoring" {
  dashboard_name = "dt-s3-log-fwd-monitoring-dashboard"

  dashboard_body = jsonencode({
    widgets: [
      {
        type: "metric",
        x: 0, y: 0, width: 12, height: 6,
        properties: {
          title: "Total Log Data Processed",
          metrics: [
            [ "Dynatrace", "ReceivedUncompressedLogPayloadSize", "FunctionName", var.lambda_name ],
            [ ".", "UncompressedLogDTPayloadSize", ".", "." ]
          ],
          stat: "Sum",
          view: "timeSeries",
          period: 300
        }
      },
      {
        type: "metric",
        x: 12, y: 0, width: 12, height: 6,
        properties: {
          title: "Lambda Execution Time (avg)",
          metrics: [
            [ "AWS/Lambda", "Duration", "FunctionName", var.lambda_name ]
          ],
          stat: "Average",
          view: "timeSeries",
          period: 300
        }
      },
      {
        type: "metric",
        x: 0, y: 6, width: 12, height: 6,
        properties: {
          title: "SQS Queue Message Volume",
          metrics: [
            [ "AWS/SQS", "ApproximateNumberOfMessagesVisible", "QueueName", var.sqs_name ]
          ],
          stat: "Sum",
          view: "timeSeries",
          period: 300
        }
      },
      {
        type: "log",
        x: 12, y: 6, width: 12, height: 6,
        properties: {
          query: "SOURCE '/aws/lambda/${var.lambda_name}' | fields @timestamp, @message | sort @timestamp desc | limit 20",
          region: var.region,
          title: "Lambda Log Stream (Recent Events)"
        }
      }
    ]
  })
}