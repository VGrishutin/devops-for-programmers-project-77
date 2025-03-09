resource "yandex_iam_service_account" "sa_tf_state_manager" {
  name        = "sa-tf-state-manager"
  description = "service account to manage terraform state"
  folder_id = var.yc_folder_id
}

resource "yandex_resourcemanager_folder_iam_member" "sa_tsa_tf_state_manager_roles_1" {
  folder_id = var.yc_folder_id
  role        = "storage.editor"
  member      = "serviceAccount:${yandex_iam_service_account.sa_tf_state_manager.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "sa_tsa_tf_state_manager_roles_2" {
  folder_id = var.yc_folder_id
  role        = "ydb.editor"
  member      = "serviceAccount:${yandex_iam_service_account.sa_tf_state_manager.id}"
}

# Создание секрета

resource "yandex_lockbox_secret" "secret_sk_sa_tsa_tf_state_manager" {
  name                = "secret-sk-sa-tsa-tf-state-manager"
  folder_id           = var.yc_folder_id
}

data "yandex_lockbox_secret_version" "ver_secret_sk_sa_tsa_tf_state_manager" {
  secret_id  = yandex_lockbox_secret.secret_sk_sa_tsa_tf_state_manager.id
  version_id = yandex_iam_service_account_static_access_key.sk_sa_tsa_tf_state_manager.output_to_lockbox_version_id
  depends_on = [
    yandex_lockbox_secret.secret_sk_sa_tsa_tf_state_manager,
    yandex_iam_service_account_static_access_key.sk_sa_tsa_tf_state_manager,
    yandex_lockbox_secret.secret_sk_sa_tsa_tf_state_manager
  ]
}

// Create Static Access Keys
resource "yandex_iam_service_account_static_access_key" "sk_sa_tsa_tf_state_manager" {
  service_account_id = yandex_iam_service_account.sa_tf_state_manager.id
  description        = "terraform s3 backend access key"
  output_to_lockbox {
    secret_id            = yandex_lockbox_secret.secret_sk_sa_tsa_tf_state_manager.id
    entry_for_access_key = "access_key"
    entry_for_secret_key = "secret_key"
  }
}

// Use keys to create bucket
resource "yandex_storage_bucket" "bucket_tf_state" {
#   access_key = yandex_iam_service_account_static_access_key.sk_sa_tsa_tf_state_manager.access_key
#   secret_key = yandex_iam_service_account_static_access_key.sk_sa_tsa_tf_state_manager.secret_key
  access_key = data.yandex_lockbox_secret_version.ver_secret_sk_sa_tsa_tf_state_manager.entries[1].text_value
  secret_key = data.yandex_lockbox_secret_version.ver_secret_sk_sa_tsa_tf_state_manager.entries[0].text_value
  bucket = "tf-bucket-${var.yc_folder_id}"
  depends_on = [
    yandex_iam_service_account_static_access_key.sk_sa_tsa_tf_state_manager
  ]
}



output "access_key" {
  value = data.yandex_lockbox_secret_version.ver_secret_sk_sa_tsa_tf_state_manager.entries[1].text_value
}

output "secret_key" {
  value = data.yandex_lockbox_secret_version.ver_secret_sk_sa_tsa_tf_state_manager.entries[0].text_value
}

output "bucket" {
  value = yandex_storage_bucket.bucket_tf_state.bucket
}

# terraform {
#   backend "s3" {
#     endpoints = {
#       s3 = "https://storage.yandexcloud.net"
#     }
#     bucket = "tf-bucket-b1g5d4t5vhk551c5k9om"
#     region = "ru-central1"
#     key    = "tf_state_lock/lock.tfstate"

#     skip_region_validation      = true
#     skip_credentials_validation = true
#     skip_requesting_account_id  = true # Необходимая опция Terraform для версии 1.6.1 и старше.
#     skip_s3_checksum            = true # Необходимая опция при описании бэкенда для Terraform версии 1.6.3 и старше.

#   }
# }

# resource "yandex_ydb_database_serverless" "tf_state" {
#   name                = "tf-state"
#   deletion_protection = false

#   serverless_database {
#     enable_throttling_rcu_limit = false
#     provisioned_rcu_limit       = 10
#     storage_size_limit          = 1
#     throttling_rcu_limit        = 0
#   }
# }


# resource "yandex_ydb_table" "lock" {
#   path = "tf_state_lock/lock"
#   connection_string = yandex_ydb_database_serverless.tf_state.ydb_full_endpoint 
  
#   column {
#     name = "LockId"
#     type = "Utf8"
#     not_null = true
#   }
#   primary_key = ["LockId"]
# }


# provider "aws" {
#   region = "ru-central1"
#   endpoints {
#     dynamodb = yandex_ydb_database_serverless.tf_state.document_api_endpoint
#   }
#   profile = "foo_profile"
#   skip_credentials_validation = true
#   skip_metadata_api_check = true
#   skip_region_validation = true
#   skip_requesting_account_id = true
# }

# resource "aws_dynamodb_table" "lock" {
#   name         = "tf_state_lock/lock"
#   billing_mode = "PAY_PER_REQUEST"

#   hash_key  = "attribute_name_1"
#   range_key = "attribute_name_2"

#   attribute {
#     name = "attribute_name_1"
#     type = "S"
#   }

#   attribute {
#     name = "attribute_name_2"
#     type = "S"
#   }
# }

