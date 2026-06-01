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
