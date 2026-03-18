# GitHub Setup — Conectar CI/CD con GCP

## Prerequisitos

- Repositorio GitHub: `jofl-nem4sis/factory-ai-sp500`
- Infraestructura GCP desplegada via Terraform (SA, WIF, BigQuery, Cloud Run, AR)

---

## 1. Configurar Workload Identity Federation en GitHub Actions

El WIF Pool y Provider ya estan creados por Terraform. Solo necesitas crear el workflow de GitHub Actions.

Crea el archivo `.github/workflows/deploy.yml` en tu repositorio:

```yaml
name: Build & Deploy SP500 Ingestor

on:
  push:
    branches: [main]

permissions:
  id-token: write   # Requerido para solicitar OIDC token
  contents: read

jobs:
  deploy:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Authenticate to Google Cloud
        uses: google-github-actions/auth@v2
        with:
          workload_identity_provider: 'projects/1076176601784/locations/global/workloadIdentityPools/github-pool/providers/github-provider'
          service_account: 'sa-sp500-ingestor@api-project-1076176601784.iam.gserviceaccount.com'

      - name: Set up Cloud SDK
        uses: google-github-actions/setup-gcloud@v2

      - name: Submit Cloud Build
        run: |
          gcloud builds submit \
            --config=cloudbuild/cloudbuild.yaml \
            --substitutions=SHORT_SHA=$(echo $GITHUB_SHA | cut -c1-7) \
            --project=api-project-1076176601784
```

### Valores clave (ya provisionados por Terraform)

| Parametro | Valor |
|---|---|
| `workload_identity_provider` | `projects/1076176601784/locations/global/workloadIdentityPools/github-pool/providers/github-provider` |
| `service_account` | `sa-sp500-ingestor@api-project-1076176601784.iam.gserviceaccount.com` |

> No necesitas crear secrets en GitHub. WIF usa tokens OIDC efimeros — sin llaves JSON.

---

## 2. Crear el Trigger de Cloud Build (alternativa a GitHub Actions)

Si prefieres usar un Cloud Build Trigger nativo en lugar de GitHub Actions:

### Opcion A: Via consola

1. Ve a [Cloud Build Triggers](https://console.cloud.google.com/cloud-build/triggers?project=api-project-1076176601784)
2. Click **"Create Trigger"**
3. Configura:
   - **Name:** `sp500-deploy`
   - **Event:** Push to a branch
   - **Source:** Conecta tu repo `jofl-nem4sis/factory-ai-sp500` (requiere instalar la app de Cloud Build en GitHub)
   - **Branch:** `^main$`
   - **Configuration:** Cloud Build configuration file
   - **Location:** `cloudbuild/cloudbuild.yaml`
   - **Service Account:** `sa-sp500-ingestor@api-project-1076176601784.iam.gserviceaccount.com`

### Opcion B: Via gcloud

```bash
# 1. Conectar repositorio (abre browser para autorizar)
gcloud builds repositories create factory-ai-sp500 \
  --remote-uri=https://github.com/jofl-nem4sis/factory-ai-sp500.git \
  --connection=github-connection \
  --region=us-central1 \
  --project=api-project-1076176601784

# 2. Crear trigger
gcloud builds triggers create github \
  --name="sp500-deploy" \
  --repository="projects/api-project-1076176601784/locations/us-central1/connections/github-connection/repositories/factory-ai-sp500" \
  --branch-pattern="^main$" \
  --build-config="cloudbuild/cloudbuild.yaml" \
  --service-account="projects/api-project-1076176601784/serviceAccounts/sa-sp500-ingestor@api-project-1076176601784.iam.gserviceaccount.com" \
  --region=us-central1 \
  --project=api-project-1076176601784
```

---

## 3. Verificar el flujo completo

Una vez configurado, cualquier `git push` a `main` deberia:

1. Disparar Cloud Build
2. Construir la imagen Docker desde `src/ingesta/`
3. Pushear a `us-central1-docker.pkg.dev/api-project-1076176601784/factory-ai-repo/sp500-ingestor`
4. Actualizar y ejecutar el Cloud Run Job `sp500-ingestor-job`
5. Ingestar datos, entrenar ARIMA_PLUS y generar predicciones

Verifica en: [Cloud Build History](https://console.cloud.google.com/cloud-build/builds?project=api-project-1076176601784)
