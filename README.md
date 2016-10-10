# sma-webhook-server
Webhook Server for Service Management Automation

Can be used to trigger an automation runbook by calling an URL.

URL to trigger a runbook is:
http://server-name:port/run/runbook-name

eg. http://localhost:8099/run/Rotate-LogFiles will trigger the Rotate-LogFiles runbook in SMA.

Call http://server-name:port/stop to stop the server.

You're able to deny access to runbooks by adding them to the $RestrictedRunbooks list inside the script.
