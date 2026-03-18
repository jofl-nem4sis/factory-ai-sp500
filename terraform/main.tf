# -----------------------------------------------------------------------------
# Root module — orquesta los 3 sub-modulos respetando el grafo de dependencias
# module.iam          → sin dependencias
# module.bigquery     → depends_on: module.iam
# module.cloud_run    → depends_on: module.iam, module.bigquery
# -----------------------------------------------------------------------------

module "iam" {
  source = "./modules/iam"

  project_id         = var.project_id
  github_owner_repo  = var.github_owner_repo
  service_account_id = var.service_account_id
}

module "bigquery" {
  source = "./modules/bigquery"

  project_id  = var.project_id
  dataset_id  = var.dataset_id
  bq_location = var.bq_location

  depends_on = [module.iam]
}

module "cloud_run" {
  source = "./modules/cloud_run"

  project_id            = var.project_id
  region                = var.region
  ar_repo_name          = var.ar_repo_name
  cloud_run_job_name    = var.cloud_run_job_name
  service_account_email = module.iam.service_account_email
  dataset_id            = module.bigquery.dataset_id
  bq_location           = var.bq_location

  depends_on = [module.iam, module.bigquery]
}
