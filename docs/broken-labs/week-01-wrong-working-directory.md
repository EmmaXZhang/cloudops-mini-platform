# Week 2 Broken Lab — Wrong WorkingDirectory

## Symptom
The `cloudops-mini-platform.service` systemd service failed to start after the `WorkingDirectory` was changed to an incorrect path.

## Initial hypothesis
My hypothesis was that systemd could not start the app because it was trying to change into a directory that did not exist.

## Evidence
`journalctl` showed:

- `Failed at step CHDIR`
- `status=200/CHDIR`
- `Changing to the requested working directory failed: No such file or directory`

## Investigation
I used the following commands:

```bash
systemctl status cloudops-mini-platform --no-pager
journalctl -u cloudops-mini-platform -n 50 --no-pager
cat /etc/systemd/system/cloudops-mini-platform.service
ls -ld /opt/cloudops-mini-platform/app
```

## Root cause
The `WorkingDirectory` value in the systemd unit file pointed to a directory that did not exist.

## Fix
I changed the `WorkingDirectory` back to:

```ini
WorkingDirectory=/opt/cloudops-mini-platform/app
```

Then reloaded systemd and restarted the service:

```bash
sudo systemctl daemon-reload
sudo systemctl restart cloudops-mini-platform
```

## Validation
After the fix:

- `systemctl status` showed `active (running)`
- `journalctl` showed `Application startup complete`
- Uvicorn started on `0.0.0.0:8080`
- `curl http://localhost:8080/health` returned `200 OK`

## Prevention
Before changing a systemd unit file, verify that all absolute paths exist. After any unit file change, run `daemon-reload`, restart the service, check `systemctl status`, inspect `journalctl`, and validate the application endpoint with `curl`.

## Interview explanation
I intentionally broke a Linux systemd service by setting an invalid `WorkingDirectory`. The service failed before the application process could start. I used `journalctl` to identify the `CHDIR` failure, checked the unit file, confirmed the correct application path, fixed the unit file, reloaded systemd, restarted the service, and validated recovery using both service status and the `/health` endpoint.
EOF
