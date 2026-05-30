# Screenshots Evidence Checklist

Save screenshots in this folder using the names below. These are the images that prove the full SOC flow worked.

Important: blur or crop any secrets before uploading screenshots publicly.

## Required screenshots

| File name | What it proves |
| --- | --- |
| `01-wazuh-agents-active.png` | Windows and Kali agents are active in Wazuh |
| `02-n8n-workflow-green.png` | n8n workflow nodes executed successfully |
| `03-n8n-execution-abuseipdb.png` | AbuseIPDB enrichment returned IP reputation data |
| `04-telegram-windows-alert.png` | Windows failed login alert reached Telegram |
| `05-telegram-kali-ssh-alert.png` | Kali SSH failed login alert reached Telegram |
| `06-terminal-agent-control.png` | `agent_control -l` shows active Wazuh agents |
| `07-terminal-windows-alert-json.png` | Wazuh alert JSON contains Windows Event ID `4625` |
| `08-terminal-kali-ssh-alert-json.png` | Wazuh alert JSON contains SSH failed login alerts |
| `09-custom-n8n-log.png` | Wazuh custom integration called n8n webhook |


## Screenshots already demonstrated during the lab

The lab already produced evidence for:

- Windows agent active
- Kali agent active
- n8n workflow green
- Telegram Windows failed login alert
- Telegram Kali SSH failed login alert
- AbuseIPDB enrichment
- Terminal proof of Wazuh alerts

