# -----------------------------------------------------------------------------
# module.bigquery — Dataset + tablas sp500_history y sp500_predictions
# -----------------------------------------------------------------------------

resource "google_bigquery_dataset" "finance" {
  dataset_id = var.dataset_id
  project    = var.project_id
  location   = var.bq_location

  delete_contents_on_destroy = true # dev environment
}

resource "google_bigquery_table" "sp500_history" {
  dataset_id          = google_bigquery_dataset.finance.dataset_id
  table_id            = "sp500_history"
  project             = var.project_id
  deletion_protection = false

  schema = jsonencode([
    { name = "Date",        type = "DATE",      mode = "REQUIRED" },
    { name = "Open",        type = "FLOAT64",   mode = "NULLABLE" },
    { name = "High",        type = "FLOAT64",   mode = "NULLABLE" },
    { name = "Low",         type = "FLOAT64",   mode = "NULLABLE" },
    { name = "Close",       type = "FLOAT64",   mode = "REQUIRED" },
    { name = "Volume",      type = "INT64",     mode = "NULLABLE" },
    { name = "ingested_at", type = "TIMESTAMP",  mode = "REQUIRED" },
  ])

  lifecycle {
    ignore_changes = [schema]
  }
}

resource "google_bigquery_table" "sp500_predictions" {
  dataset_id          = google_bigquery_dataset.finance.dataset_id
  table_id            = "sp500_predictions"
  project             = var.project_id
  deletion_protection = false

  schema = jsonencode([
    { name = "forecast_timestamp",              type = "TIMESTAMP", mode = "REQUIRED" },
    { name = "forecast_value",                  type = "FLOAT64",   mode = "NULLABLE" },
    { name = "standard_error",                  type = "FLOAT64",   mode = "NULLABLE" },
    { name = "confidence_level",                type = "FLOAT64",   mode = "NULLABLE" },
    { name = "prediction_interval_lower_bound", type = "FLOAT64",   mode = "NULLABLE" },
    { name = "prediction_interval_upper_bound", type = "FLOAT64",   mode = "NULLABLE" },
    { name = "model_trained_at",                type = "TIMESTAMP", mode = "REQUIRED" },
  ])

  lifecycle {
    ignore_changes = [schema]
  }
}
