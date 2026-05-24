# CloudOps Mini Platform App

This is a simple operations-friendly FastAPI application used for CloudOps and DevOps learning.

## Endpoints

| Endpoint          | Purpose                                             |
| ----------------- | --------------------------------------------------- |
| `/`               | Root endpoint showing the app is running            |
| `/health`         | Health check endpoint                               |
| `/ready`          | Readiness check endpoint                            |
| `/version`        | Shows app version and environment                   |
| `/metrics-lite`   | Shows simple uptime information                     |
| `/simulate-error` | Returns a controlled 500 error for incident testing |

## Run locally

```bash
cd app
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
uvicorn src.main:app --reload --host 0.0.0.0 --port 8080
```
