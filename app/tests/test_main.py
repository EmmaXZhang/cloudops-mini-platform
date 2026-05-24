from fastapi.testclient import TestClient
from src.main import app

client = TestClient(app)

def test_root_endpoint():
    response=client.get("/")
    assert response.status_code==200
    assert response.json()["service"] == "cloudops-mini-platform"

def test_health_endpoint():
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json()["status"] == "healthy"


def test_ready_endpoint():
    response = client.get("/ready")
    assert response.status_code == 200
    assert response.json()["status"] == "ready"


def test_version_endpoint():
    response = client.get("/version")
    assert response.status_code == 200
    assert "version" in response.json()


def test_metrics_lite_endpoint():
    response = client.get("/metrics-lite")
    assert response.status_code == 200
    assert "uptime_seconds" in response.json()


def test_simulate_error_endpoint():
    response = client.get("/simulate-error")
    assert response.status_code == 500
    assert response.json()["status"] == "error"
