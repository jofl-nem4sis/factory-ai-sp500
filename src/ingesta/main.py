"""SP500 Ingestor — descarga datos, entrena ARIMA_PLUS, genera predicciones."""

from datetime import datetime, timezone

import yfinance as yf
from google.cloud import bigquery

import config


def get_bq_client() -> bigquery.Client:
    return bigquery.Client(project=config.PROJECT_ID, location=config.BQ_LOCATION)


def ingest_data(client: bigquery.Client) -> int:
    """Descarga datos historicos del S&P 500 y los carga en BigQuery."""
    print(f"Descargando {config.TICKER_SYMBOL} periodo={config.HISTORY_PERIOD}...")
    df = yf.download(config.TICKER_SYMBOL, period=config.HISTORY_PERIOD, auto_adjust=True)

    if df.empty:
        raise RuntimeError(f"yfinance devolvio DataFrame vacio para {config.TICKER_SYMBOL}")

    # Flatten MultiIndex columns if present (yfinance >= 0.2.36)
    if hasattr(df.columns, "droplevel") and df.columns.nlevels > 1:
        df.columns = df.columns.droplevel(1)

    df = df.reset_index()
    df["ingested_at"] = datetime.now(timezone.utc)

    job_config = bigquery.LoadJobConfig(
        write_disposition=bigquery.WriteDisposition.WRITE_APPEND,
        schema_update_options=[
            bigquery.SchemaUpdateOption.ALLOW_FIELD_ADDITION,
        ],
    )

    table_ref = f"{config.PROJECT_ID}.{config.BQ_DATASET}.{config.BQ_TABLE_HISTORY}"
    print(f"Cargando {len(df)} filas en {table_ref}...")
    job = client.load_table_from_dataframe(df, table_ref, job_config=job_config)
    job.result()
    print(f"Carga completada: {job.output_rows} filas escritas.")
    return job.output_rows


def train_model(client: bigquery.Client) -> None:
    """Entrena (o re-entrena) el modelo ARIMA_PLUS en BigQuery ML."""
    sql = f"""
    CREATE OR REPLACE MODEL `{config.MODEL_FQ}`
    OPTIONS (
        model_type = 'ARIMA_PLUS',
        time_series_timestamp_col = 'Date',
        time_series_data_col = 'Close'
    ) AS
    SELECT Date, Close
    FROM `{config.TABLE_HISTORY_FQ}`
    """
    print(f"Entrenando modelo {config.MODEL_FQ}...")
    job = client.query(sql)
    job.result()
    print("Modelo entrenado exitosamente.")


def generate_predictions(client: bigquery.Client) -> int:
    """Genera predicciones con ML.FORECAST y las inserta en sp500_predictions."""
    now = datetime.now(timezone.utc).isoformat()

    sql = f"""
    INSERT INTO `{config.TABLE_PREDICTIONS_FQ}`
        (forecast_timestamp, forecast_value, standard_error,
         confidence_level, prediction_interval_lower_bound,
         prediction_interval_upper_bound, model_trained_at)
    SELECT
        forecast_timestamp,
        forecast_value,
        standard_error,
        confidence_level,
        prediction_interval_lower_bound,
        prediction_interval_upper_bound,
        TIMESTAMP('{now}') AS model_trained_at
    FROM ML.FORECAST(MODEL `{config.MODEL_FQ}`,
                     STRUCT(30 AS horizon, 0.95 AS confidence_level))
    """
    print("Generando predicciones (horizon=30 dias)...")
    job = client.query(sql)
    job.result()
    rows = job.num_dml_affected_rows or 0
    print(f"Predicciones insertadas: {rows} filas.")
    return rows


def main():
    print("=" * 60)
    print("SP500 Ingestor — Inicio")
    print(f"  Project:  {config.PROJECT_ID}")
    print(f"  Dataset:  {config.BQ_DATASET}")
    print(f"  Ticker:   {config.TICKER_SYMBOL}")
    print(f"  Periodo:  {config.HISTORY_PERIOD}")
    print("=" * 60)

    client = get_bq_client()

    ingest_data(client)
    train_model(client)
    generate_predictions(client)

    print("Pipeline completado exitosamente.")


if __name__ == "__main__":
    main()
