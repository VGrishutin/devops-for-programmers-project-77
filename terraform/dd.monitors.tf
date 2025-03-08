resource "datadog_monitor" "hostname_is_unavailable" {
  new_group_delay = 60
  no_data_timeframe = 2
  notify_no_data = true
  require_full_window = false
  monitor_thresholds {
    critical = 1
    ok = 1
    warning = 1
  }
  name = "{{host.name}} is unavailable"
  type = "service check"
  query = <<EOT
"datadog.agent.up".over("*").by("host").last(2).count_by_status()
EOT
  message = <<EOT
{{#is_alert}}
  {{host.name}} is unavailable
{{/is_alert}}
EOT
}

resource "datadog_synthetics_test" "test_uptime" {
  name      = "An Uptime test on hexlet-p2.mexaho.online"
  type      = "api"
  subtype   = "http"
  status    = "live"
  message   = "Notify @pagerduty"
  locations = ["aws:eu-central-1"]
  tags      = ["foo"]

  request_definition {
    method = "GET"
    url    = "https://hexlet-p2.mexaho.online/"
  }

  request_headers = {
    Content-Type = "application/json"
  }

  assertion {
    type     = "statusCode"
    operator = "is"
    target   = "200"
  }

  options_list {
    tick_every = 900
    retry {
      count    = 2
      interval = 300
    }
    monitor_options {
      renotify_interval = 120
    }
  }
}