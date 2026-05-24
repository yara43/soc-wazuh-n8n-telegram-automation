# Final Project Report

## Project Title

Automated SOC Incident Response Lab using Wazuh, n8n, AbuseIPDB, and Telegram

## Executive Summary

This project implemented a working SOC automation lab where Wazuh detects endpoint security alerts, n8n receives and processes the alert data, AbuseIPDB enriches source IP addresses, and Telegram sends analyst-ready incident notifications.

The lab successfully demonstrated detection and automated alerting for Windows failed login events and Kali Linux SSH failed login events.

## Architecture

```text
Windows Agent / Kali Agent
        |
        v
Wazuh Manager
        |
        v
custom-n8n integration
        |
        v
n8n Webhook
        |
        v
Normalize -> AbuseIPDB -> Format Alert -> Telegram
```

## Assets

| Asset | Role |
|---|---|
| Ubuntu Server | Wazuh and n8n host |
| Windows 10 VM | Monitored endpoint |
| Kali Linux VM | Monitored endpoint and SSH test target |
| Telegram Bot | Analyst notification channel |
| AbuseIPDB | IP reputation enrichment |

## Implemented Detection Logic

### Windows Failed Login

Detected by:

```text
Event ID: 4625
Wazuh Rule: 60122
```

Mapped to:

```text
MITRE ATT&CK: T1110 - Brute Force
Risk Level: High
```

### SSH Failed Login

Detected by:

```text
Wazuh Rule: 5710
Log content: Failed password / Invalid user / sshd
```

Mapped to:

```text
MITRE ATT&CK: T1110 - Brute Force
Risk Level: High
```

## Threat Intelligence Enrichment

AbuseIPDB was used to enrich source IPs with:

- Abuse confidence score
- Total reports
- Country code
- ISP
- Domain
- Last reported date

Private lab IPs such as `192.168.x.x` and `127.0.0.1` may return no public reputation data, which is expected.

## Automation Output

Telegram alerts include:

- Alert type
- Host
- Agent IP
- Source IP
- Rule description
- Rule ID
- Event ID
- Risk score
- MITRE technique
- AbuseIPDB enrichment
- Recommended action
- Timestamp

## Evidence Collected

Recommended screenshots:

- Wazuh agents active.
- n8n workflow with all nodes green.
- AbuseIPDB node successful output.
- Telegram Windows alert.
- Telegram Kali SSH alert.
- Terminal output showing Windows failed login alert.
- Terminal output showing Kali SSH failed login alert.

## Issues Faced and Resolved

### n8n Secure Cookie Error

Fixed by running n8n with:

```bash
-e N8N_SECURE_COOKIE=false
```

### Wazuh Disk Full

The VM disk became full due to vulnerability feed data under:

```text
/var/ossec/queue/vd
/var/ossec/queue/vd_updater
```

Resolved by cleaning the feed cache and freeing disk space.

### Dashboard Not Ready

Wazuh Dashboard sometimes required restarting Wazuh Indexer and Dashboard services. Terminal evidence was used as backup proof when the dashboard was unavailable.

## Lessons Learned

- Endpoint agents are required for host-level visibility.
- SIEM alerts become more useful when normalized and enriched.
- SOAR workflows reduce manual triage time.
- Private IPs do not provide useful AbuseIPDB reputation.
- Disk sizing matters when running Wazuh components in a small VM.
- Screenshots and command outputs are important for documenting SOC projects.

## Final Status

The lab successfully demonstrates:

- Log collection from Windows and Kali Linux.
- Wazuh alert generation.
- n8n alert intake and processing.
- AbuseIPDB enrichment.
- Risk scoring.
- MITRE mapping.
- Telegram analyst notifications.

