# 🌍 Environment Manifest: Factory_IA

## ☁️ Provider: Google Cloud Platform (GCP)
- **Project ID:** api-project-1076176601784
- **Region:** us-central1
- **Environment:** Development

## 🔑 Identity & Access (IAM)
- **Service Account:** `sa-sp500-ingestor@api-project-1076176601784.iam.gserviceaccount.com`
- **Auth Method:** Workload Identity Federation (WIF) para CI/CD, ADC para desarrollo local
- **WIF Pool:** `github-pool` / Provider: `github-provider`

## 📊 Data Landscape (BigQuery)
- **Dataset:** `factory_ia_finance`
- **Tables:**
  - `sp500_history`: Datos crudos de yfinance (5 años de histórico).
  - `sp500_predictions`: Resultados del modelo ML (30 días de forecast).
- **Model:** `arima_sp500_close` (ARIMA_PLUS sobre columna `Close`)

## 🤖 AI/ML Specs
- **Model Type:** ARIMA_PLUS (Time Series)
- **Target Variable:** `Close`
- **History Period:** 5y
- **Forecast Horizon:** 30 días

## 🛠️ DevOps & CI/CD Stack
- **Source:** GitHub Repository (`jofl-nem4sis/factory-ai-sp500`)
- **Build Service:** Cloud Build
- **Artifacts:** Artifact Registry (Docker Repository: `factory-ai-repo`)
- **IaC Tool:** Terraform v1.5+
- **Backend State:** GCS Bucket (`tfstate-api-project-1076176601784`)

## 🏗️ Compute (Cloud Run)
- **Service Name:** `sp500-ingestor-job`
- **Region:** us-central1
- **Tipo:** Job (no Service — sin endpoints HTTP)