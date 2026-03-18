variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
}

variable "ar_repo_name" {
  description = "Artifact Registry repository name"
  type        = string
}

variable "cloud_run_job_name" {
  description = "Cloud Run Job name"
  type        = string
}

variable "service_account_email" {
  description = "Service account email for the job"
  type        = string
}

variable "dataset_id" {
  description = "BigQuery dataset ID"
  type        = string
}

variable "bq_location" {
  description = "BigQuery dataset location"
  type        = string
}
