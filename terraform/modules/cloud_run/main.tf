# -----------------------------------------------------------------------------
# module.cloud_run — Artifact Registry repo + Cloud Run Job
# -----------------------------------------------------------------------------

resource "google_artifact_registry_repository" "docker" {
  location      = var.region
  repository_id = var.ar_repo_name
  format        = "DOCKER"
  project       = var.project_id
}

locals {
  image_uri = "${var.region}-docker.pkg.dev/${var.project_id}/${var.ar_repo_name}/sp500-ingestor:latest"
}

resource "google_cloud_run_v2_job" "ingestor" {
  name     = var.cloud_run_job_name
  location = var.region
  project  = var.project_id

  template {
    template {
      service_account = var.service_account_email
      max_retries     = 1

      containers {
        image = local.image_uri

        env {
          name  = "GCP_PROJECT_ID"
          value = var.project_id
        }
        env {
          name  = "BQ_DATASET"
          value = var.dataset_id
        }
        env {
          name  = "BQ_TABLE_HISTORY"
          value = "sp500_history"
        }
        env {
          name  = "BQ_TABLE_PREDICTIONS"
          value = "sp500_predictions"
        }
        env {
          name  = "BQ_LOCATION"
          value = var.bq_location
        }
        env {
          name  = "TICKER_SYMBOL"
          value = "^GSPC"
        }
        env {
          name  = "HISTORY_PERIOD"
          value = "5y"
        }
        env {
          name  = "ML_MODEL_NAME"
          value = "arima_sp500_close"
        }
      }
    }
  }

  lifecycle {
    ignore_changes = [
      template[0].template[0].containers[0].image,
    ]
  }
}
