# Объявление переменных для конфиденциальных параметров

variable "yc_folder_id" {
  type = string
}

variable "domain" {
  type = string
}

variable "certificate" {
  type = string
}

variable "private_key" {
  type = string
}

// Terraform должен знать ключ, для выполнения команд по API - из секректов
variable "yc_token" {
  type        = string
  description = "Yandex Cloud auth token"
  sensitive   = true
}

variable "yc_org_id" {
  type        = string
  description = "Yandex Cloud organization id"
}

variable "yc_cloud_id" {
  type        = string
  description = "Yandex Cloud id"
}

variable "yc_zone" {
  type        = string
  description = "Yandex Cloud compute default zone"
  default     = "ru-central1-b"
}

