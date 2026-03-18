terraform {
  backend "gcs" {
    bucket = "tfstate-api-project-1076176601784"
    prefix = "terraform/state"
  }
}
