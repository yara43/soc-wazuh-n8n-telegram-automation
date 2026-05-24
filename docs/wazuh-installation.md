# Wazuh Installation and Troubleshooting

## Main Wazuh Components

| Component | Purpose |
|---|---|
| Wazuh Manager | Receives and analyzes logs from agents |
| Wazuh Agent | Installed on endpoints to forward logs |
| Wazuh Indexer | Stores indexed alert data |
| Wazuh Dashboard | Web interface for visibility and investigation |

## Service Checks

```bash
sudo systemctl status wazuh-manager --no-pager
sudo systemctl status wazuh-indexer --no-pager
sudo systemctl status wazuh-dashboard --no-pager
sudo /var/ossec/bin/wazuh-control status
```

## Agent Check

```bash
sudo /var/ossec/bin/agent_control -l
```

## Dashboard URL

```text
https://192.168.86.146
```

If the browser says the dashboard is not ready yet, wait a few minutes and check:

```bash
sudo systemctl status wazuh-indexer --no-pager
sudo systemctl status wazuh-dashboard --no-pager
sudo ss -tulnp | grep -E ':443|:5601|:9200'
```

## Indexer Requirement

Wazuh Indexer requires a high enough `vm.max_map_count`.

```bash
sudo sysctl -w vm.max_map_count=262144
echo "vm.max_map_count=262144" | sudo tee -a /etc/sysctl.conf
sudo systemctl reset-failed wazuh-indexer
sudo systemctl restart wazuh-indexer
```

## OpenSearch Security Not Initialized

If this appears:

```text
OpenSearch Security not initialized.
```

Run:

```bash
sudo /usr/share/wazuh-indexer/bin/indexer-security-init.sh
sudo systemctl restart wazuh-indexer
sudo systemctl restart wazuh-dashboard
```

## Disk Full Issue

During the lab, the Ubuntu disk became full because vulnerability feed data grew inside:

```text
/var/ossec/queue/vd
/var/ossec/queue/vd_updater
```

Check disk:

```bash
df -h
sudo du -xh --max-depth=1 /var | sort -h
sudo du -xhd1 /var/ossec/queue | sort -h
```

Emergency cleanup used in the lab:

```bash
sudo systemctl stop wazuh-manager
sudo find /var/ossec/queue/vd -mindepth 1 -delete
sudo find /var/ossec/queue/vd_updater -mindepth 1 -delete
df -h
```

## Recommended Small-Lab Optimization

For a small VM, disable vulnerability feed updates to prevent disk pressure.

Create a backup first:

```bash
sudo cp /var/ossec/etc/ossec.conf /var/ossec/etc/ossec.conf.bak
```

Edit:

```bash
sudo nano /var/ossec/etc/ossec.conf
```

Disable vulnerability detection if enabled:

```xml
<vulnerability-detection>
  <enabled>no</enabled>
</vulnerability-detection>
```

Then test and restart:

```bash
sudo /var/ossec/bin/wazuh-analysisd -t
sudo systemctl restart wazuh-manager
```

## Useful Alert Search Commands

Windows failed login:

```bash
sudo grep -i "Logon Failure" /var/ossec/logs/alerts/alerts.json | tail -n 1
```

Kali SSH failed login:

```bash
sudo grep -i "Failed password\|Invalid user\|sshd" /var/ossec/logs/alerts/alerts.json | tail -n 3
```

Integration troubleshooting:

```bash
sudo grep -i "custom-n8n\|integrator\|integration" /var/ossec/logs/ossec.log | tail -n 30
sudo cat /tmp/custom-n8n.log | tail -n 30
```

