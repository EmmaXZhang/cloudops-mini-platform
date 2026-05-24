import os
import time
from fastapi import FastAPI, Response, status

APP_NAME = os.getenv("APP_NAME", "cloudops-mini-platform")
APP_VERSION = os.getenv("APP_VERSION", "0.1.0")
APP_ENV = os.getenv("APP_ENV","local")

START_TIME = time.time()
app= FastAPI (title=APP_NAME)

@app.get("/")
def root():
    return {
    "service": APP_NAME,
    "message": "CloudOps Mini Platform is running",
    "environment": APP_ENV,
    }

@app.get("/health")
def health():
    return {
        "status": "healthy",
        "service": APP_NAME,
    }

@app.get("/ready")
def ready():
    return {
        "status": "ready",
        "dependencies":{
            "database":"not_required",
            "external_api":"not_required",
        }
    } 

@app.get("/version")
def version():
    return {
        "service": APP_NAME,
        "version": APP_VERSION,
        "environment": APP_ENV,
    }

@app.get("/metrics-lite")
def metrics_lite():
    uptime_seconds = int(time.time()-START_TIME)
    return {
        "service": APP_NAME,
        "uptime_seconds": uptime_seconds,
        "status": "running",
    }



# Response => HTTP Response object, give it variable name response.
@app.get("/simulate-error")
def simulate_error(response: Response):
    response.status_code=status.HTTP_500_INTERNAL_SERVER_ERROR
    return{
        "status":"error",
        "message":"Simulated application error for incident testing",
    }
