variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP region for all resources"
  type        = string
}

variable "github_owner_repo" {
  description = "GitHub owner/repo for WIF attribute condition (e.g. jofl-nem4sis/factory-ai-sp500)"
  type        = string
}

variable "service_account_id" {
  description = "ID of the service account (without @project.iam...)"
  type        = string
  default     = "sa-sp500-ingestor"
}

variable "dataset_id" {
  description = "BigQuery dataset ID"
  type        = string
  default     = "factory_ia_finance"
}

variable "bq_location" {
  description = "BigQuery dataset location"
  type        = string
  default     = "us-central1"
}

variable "ar_repo_name" {
  description = "Artifact Registry repository name"
  type        = string
  default     = "factory-ai-repo"
}

variable "cloud_run_job_name" {
  description = "Cloud Run Job name"
  type        = string
  default     = "sp500-ingestor-job"
}
