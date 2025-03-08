
variable "yc_postgresql_version" {
  type        = string
  description = "Postgesql db server version"
  default     = "16"
}

variable "db_user" {
  type        = string
  description = "Postgesql db server version"
  default     = "redmine-user"
}


variable "db_name" {
  type        = string
  description = "Postgesql db server version"
  default     = "redmine-db"
}

variable "db_password" {
  type        = string
  description = "Postgesql db server version"
  default     = "password"
}

variable "db_host_name" {
  type        = string
  description = "Postgesql db host name"
  default     = "postgres-db"
}
