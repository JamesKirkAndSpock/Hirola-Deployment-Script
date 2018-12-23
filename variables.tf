variable "region" {
  type    = "string"
  default = "us-east1"
}

variable "zone" {
  type    = "string"
  default = "us-east1-b"
}

variable "project" {}

variable "ip-address" {}

variable "env" {}

variable "branch" {}

variable "host" {}

variable "database_password" {}

variable "database_user" {}

variable "database_name" {}

variable "postgres_ip" {}

variable "environment" {}

variable "gs_bucket_name" {}

variable "gs_bucket_url" {}

variable "cache_port" {}

variable "cache_ip" {}

variable "twilio_account_sid" {}

variable "twilio_auth_token" {}

variable "email_host" {}

variable "email_port" {}

variable "email_host_user" {}

variable "email_host_password" {}

variable "default_from_email" {}

variable "session_cookie_age" {}

variable "session_cookie_age_known_device" {}

variable "secret_gs_bucket_name" {}

variable "change_email_expiry_minutes_time" {}

variable "inactive_email_expiry_minutes_time" {}
