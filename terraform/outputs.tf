output "service_account_email" {
  description = "Email of the service account"
  value       = module.iam.service_account_email
}

output "wif_provider_name" {
  description = "Full resource name of the WIF provider (for GitHub Actions)"
  value       = module.iam.wif_provider_name
}

output "dataset_id" {
  description = "BigQuery dataset ID"
  value       = module.bigquery.dataset_id
}

output "cloud_run_job_name" {
  description = "Cloud Run Job name"
  value       = module.cloud_run.job_name
}

output "artifact_registry_repo" {
  description = "Artifact Registry repository URL"
  value       = module.cloud_run.ar_repo_url
}
