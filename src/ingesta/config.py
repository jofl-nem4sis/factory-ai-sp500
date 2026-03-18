"""Configuracion centralizada — lee variables de entorno del Cloud Run Job."""

import os

PROJECT_ID = os.environ["GCP_PROJECT_ID"]
BQ_DATASET = os.environ["BQ_DATASET"]
BQ_TABLE_HISTORY = os.environ["BQ_TABLE_HISTORY"]
BQ_TABLE_PREDICTIONS = os.environ["BQ_TABLE_PREDICTIONS"]
BQ_LOCATION = os.environ["BQ_LOCATION"]
TICKER_SYMBOL = os.environ.get("TICKER_SYMBOL", "^GSPC")
HISTORY_PERIOD = os.environ.get("HISTORY_PERIOD", "5y")
ML_MODEL_NAME = os.environ.get("ML_MODEL_NAME", "arima_sp500_close")

# Fully qualified table references
TABLE_HISTORY_FQ = f"{PROJECT_ID}.{BQ_DATASET}.{BQ_TABLE_HISTORY}"
TABLE_PREDICTIONS_FQ = f"{PROJECT_ID}.{BQ_DATASET}.{BQ_TABLE_PREDICTIONS}"
MODEL_FQ = f"{PROJECT_ID}.{BQ_DATASET}.{ML_MODEL_NAME}"
