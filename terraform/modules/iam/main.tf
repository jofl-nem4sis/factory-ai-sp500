# -----------------------------------------------------------------------------
# module.iam — Service Account, Workload Identity Federation, IAM bindings
# -----------------------------------------------------------------------------

resource "google_service_account" "sp500_ingestor" {
  account_id   = var.service_account_id
  display_name = "SP500 Ingestor Service Account"
  project      = var.project_id
}

# --- Workload Identity Federation ---

resource "google_iam_workload_identity_pool" "github" {
  provider                  = google-beta
  project                   = var.project_id
  workload_identity_pool_id = "github-pool"
  display_name              = "GitHub Actions Pool"
}

resource "google_iam_workload_identity_pool_provider" "github" {
  provider                           = google-beta
  project                            = var.project_id
  workload_identity_pool_id          = google_iam_workload_identity_pool.github.workload_identity_pool_id
  workload_identity_pool_provider_id = "github-provider"
  display_name                       = "GitHub Actions Provider"

  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.actor"      = "assertion.actor"
    "attribute.repository" = "assertion.repository"
  }

  attribute_condition = "assertion.repository == \"${var.github_owner_repo}\""

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}

# --- Vincular el pool con la Service Account ---

resource "google_service_account_iam_binding" "wif_binding" {
  service_account_id = google_service_account.sp500_ingestor.name
  role               = "roles/iam.workloadIdentityUser"

  members = [
    "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github.name}/attribute.repository/${var.github_owner_repo}"
  ]
}

# --- Roles de la Service Account en el proyecto ---

locals {
  sa_roles = [
    "roles/cloudbuild.builds.editor",
    "roles/artifactregistry.writer",
    "roles/run.admin",
    "roles/bigquery.dataEditor",
    "roles/bigquery.jobUser",
  ]
}

resource "google_project_iam_member" "sa_roles" {
  for_each = toset(local.sa_roles)

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.sp500_ingestor.email}"
}
