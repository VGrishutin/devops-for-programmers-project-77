terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = ">= 0.47.0"
      # source = "terraform-registry.storage.yandexcloud.net/yandex-cloud/yandex" # Alternate link
    }
    datadog = {
      source  = "DataDog/datadog"
      version = ">= 3.57.0"
    }
    # ansible = {
    #   source  = "ansible/ansible"
    #   version = "~> 1.3.0"
    # }    
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  token     = var.yc_token     # Set OAuth or IAM token
  cloud_id  = var.yc_cloud_id  # Set your cloud ID
  folder_id = var.yc_folder_id # Set your cloud folder ID
  zone      = var.yc_zone      # Availability zone by default, one of ru-central1-a, ru-central1-b, ru-central1-c
}


# Configure the Datadog provider
provider "datadog" {
  api_key = var.datadog_api_key
  app_key = var.datadog_app_key
  api_url = "https://app.datadoghq.eu/api/"
}