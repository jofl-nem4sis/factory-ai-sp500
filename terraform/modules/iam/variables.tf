variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "github_owner_repo" {
  description = "GitHub owner/repo (e.g. jofl-nem4sis/factory-ai-sp500)"
  type        = string
}

variable "service_account_id" {
  description = "Service account ID (without @project.iam...)"
  type        = string
}
