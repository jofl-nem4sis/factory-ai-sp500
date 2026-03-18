output "dataset_id" {
  description = "BigQuery dataset ID"
  value       = google_bigquery_dataset.finance.dataset_id
}

output "table_history_id" {
  description = "BigQuery sp500_history table ID"
  value       = google_bigquery_table.sp500_history.table_id
}

output "table_predictions_id" {
  description = "BigQuery sp500_predictions table ID"
  value       = google_bigquery_table.sp500_predictions.table_id
}
