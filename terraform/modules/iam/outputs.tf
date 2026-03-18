output "service_account_email" {
  description = "Email of the service account"
  value       = google_service_account.sp500_ingestor.email
}

output "wif_provider_name" {
  description = "Full resource name of the WIF provider (for GitHub Actions auth)"
  value       = google_iam_workload_identity_pool_provider.github.name
}
