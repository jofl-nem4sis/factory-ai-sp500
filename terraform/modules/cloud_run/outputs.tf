output "job_name" {
  description = "Cloud Run Job name"
  value       = google_cloud_run_v2_job.ingestor.name
}

output "ar_repo_url" {
  description = "Artifact Registry repository URL"
  value       = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.docker.repository_id}"
}
