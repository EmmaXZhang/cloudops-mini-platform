# Wrong ALB Health-Check Path

## Baseline
The target was healthy and the ALB returned HTTP 200.

## Change Introduced
Changed the health-check path from `/health` to `/wrong-health-path`.

## Symptom
The target became unhealthy and AWS reported `Target.ResponseCodeMismatch`.

## Evidence
The configured path returned HTTP 404, while `/health` still returned HTTP 200 locally.

## Root Cause
The target group was checking a nonexistent endpoint.

## Recovery
Restored the health-check path to `/health`.

## Validation
The target returned to healthy and the ALB health endpoint returned HTTP 200.
