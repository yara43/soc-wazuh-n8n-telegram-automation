# Configurations

This folder contains sanitized configuration snippets used in the lab.

## Files

| File | Purpose |
| --- | --- |
| `custom-n8n.sh` | Wazuh custom integration script that forwards failed-login alerts to n8n |
| `ossec-integration-snippet.xml` | Wazuh `ossec.conf` integration block |

## Install the custom integration

On the Ubuntu Wazuh server:

```bash
sudo nano /var/ossec/integrations/custom-n8n
sudo chown root:wazuh /var/ossec/integrations/custom-n8n
sudo chmod 750 /var/ossec/integrations/custom-n8n
```

Then add the XML block from `ossec-integration-snippet.xml` into:

```bash
sudo nano /var/ossec/etc/ossec.conf
```

Validate and restart:

```bash
sudo /var/ossec/bin/wazuh-analysisd -t
sudo systemctl restart wazuh-manager
```

Check the integration log:

```bash
sudo cat /tmp/custom-n8n.log | tail -n 30
```

## Security

Do not place Telegram tokens, AbuseIPDB API keys, Wazuh passwords, private keys, or certificates in this folder.
