1. what workingdirectory does in a systemd service
working directory tell systemd service to where to start the service.
2. why the servce failed before the application started
systemd checed the wrong working directory so there is no configuraiton file stored there
3. what status=200/CHIDIR indicated

4. how you found the correct directory

/etc/
5. how do you verified recovery
systemctl status servicenname
