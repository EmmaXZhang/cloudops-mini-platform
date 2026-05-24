# App Design

## Purpose

The CloudOps Mini Platform app is a simple operational web service designed for CloudOps and DevOps practice.

The app is not intended to be feature-rich. Its purpose is to behave like a real service that can be deployed, monitored, tested, and troubleshot.

## Endpoints

### `/`

Confirms the service is running.

### `/health`

Used for health checks.

### `/ready`

Used to confirm the service is ready to receive traffic.

### `/version`

Returns app version and environment.

### `/metrics-lite`

Returns simple uptime information.

### `/simulate-error`

Returns a controlled HTTP 500 error for incident simulation.

## Why this design matters

This app supports realistic operations activities:

- local testing
- health checks
- readiness checks
- version validation
- monitoring
- alerting
- incident simulation
- Docker smoke tests
- ALB target group health checks
- Kubernetes probes

## Future improvements

- Add structured logging
- Add request count metric
- Add environment-specific config
- Add Docker healthcheck
- Add CI/CD smoke test
