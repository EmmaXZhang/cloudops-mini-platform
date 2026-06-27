#!/usr/bin/env bash
set -Eeuo pipefail

IMAGE_URI="${1:?Usage: deploy-container.sh <image-uri>}"
AWS_REGION="ap-southeast-2"

APP_CONTAINER="cloudops-mini-platform"
CANDIDATE_CONTAINER="cloudops-candidate"
SYSTEMD_SERVICE="cloudops-mini-platform"

REGISTRY="${IMAGE_URI%%/*}"

echo "Deploying: ${IMAGE_URI}"

aws ecr get-login-password \
  --region "${AWS_REGION}" \
  | docker login \
      --username AWS \
      --password-stdin "${REGISTRY}"

docker pull "${IMAGE_URI}"

# Test the new image without touching the running application.
docker rm -f "${CANDIDATE_CONTAINER}" 2>/dev/null || true

docker run -d \
  --name "${CANDIDATE_CONTAINER}" \
  -p 18080:8080 \
  -e ENVIRONMENT=aws-dev \
  "${IMAGE_URI}"

candidate_healthy=false

for attempt in {1..20}; do
  if curl -fsS http://127.0.0.1:18080/health >/dev/null; then
    candidate_healthy=true
    break
  fi

  echo "Waiting for candidate: ${attempt}/20"
  sleep 2
done

if [[ "${candidate_healthy}" != "true" ]]; then
  echo "Candidate failed health check"
  docker logs "${CANDIDATE_CONTAINER}" || true
  docker rm -f "${CANDIDATE_CONTAINER}" || true
  exit 1
fi

echo "Candidate passed health check"
docker rm -f "${CANDIDATE_CONTAINER}"

# Record the current runtime so it can be restored.
PREVIOUS_IMAGE="$(
  docker inspect \
    --format '{{.Config.Image}}' \
    "${APP_CONTAINER}" 2>/dev/null || true
)"

SYSTEMD_WAS_ACTIVE="$(
  systemctl is-active "${SYSTEMD_SERVICE}" 2>/dev/null || true
)"

rollback() {
  echo "Deployment failed. Rolling back."

  docker rm -f "${APP_CONTAINER}" 2>/dev/null || true

  if [[ -n "${PREVIOUS_IMAGE}" ]]; then
    echo "Restoring previous image: ${PREVIOUS_IMAGE}"

    docker run -d \
      --name "${APP_CONTAINER}" \
      --restart unless-stopped \
      -p 8080:8080 \
      -e ENVIRONMENT=aws-dev \
      "${PREVIOUS_IMAGE}"
  elif [[ "${SYSTEMD_WAS_ACTIVE}" == "active" ]]; then
    echo "Restoring systemd application"
    systemctl start "${SYSTEMD_SERVICE}"
  fi
}

# Stop whichever version currently owns port 8080.
systemctl stop "${SYSTEMD_SERVICE}" 2>/dev/null || true
docker rm -f "${APP_CONTAINER}" 2>/dev/null || true

docker run -d \
  --name "${APP_CONTAINER}" \
  --restart unless-stopped \
  -p 8080:8080 \
  -e ENVIRONMENT=aws-dev \
  "${IMAGE_URI}"

production_healthy=false

for attempt in {1..20}; do
  if curl -fsS http://127.0.0.1:8080/health >/dev/null; then
    production_healthy=true
    break
  fi

  echo "Waiting for deployed container: ${attempt}/20"
  sleep 2
done

if [[ "${production_healthy}" != "true" ]]; then
  echo "Deployed container failed health check"
  docker logs "${APP_CONTAINER}" || true
  rollback
  exit 1
fi

echo "Deployment successful"
docker inspect "${APP_CONTAINER}" \
  --format 'Image={{.Config.Image}} Status={{.State.Status}}'
