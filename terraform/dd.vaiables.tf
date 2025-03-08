# Объявление переменных для конфиденциальных параметров
variable "datadog_api_key" {
  type        = string
  description = "datadog api token"
  sensitive   = true
}

variable "datadog_app_key" {
  type        = string
  description = "datadog app token"
  sensitive   = true
}

