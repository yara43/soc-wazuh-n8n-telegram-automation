# n8n Workflow Documentation

## Workflow Name

```text
Wazuh Alert Intake
```

## Purpose

This workflow receives Wazuh alerts, normalizes fields, enriches the source IP using AbuseIPDB, calculates risk, maps the alert to MITRE ATT&CK, and sends a Telegram notification to the analyst.

## Workflow Flow

```text
Webhook -> Normalize Wazuh Alert -> AbuseIPDB Check -> Format Telegram Alert -> Telegram HTTP Request
```

## 1. Webhook Node

Purpose:

- Receive Wazuh alerts in JSON format.

Settings:

```text
HTTP Method: POST
Path: wazuh-alert
Authentication: None
Production URL: http://localhost:5678/webhook/wazuh-alert
```

## 2. Normalize Wazuh Alert Node

Purpose:

- Extract fields from both simple test JSON and real Wazuh JSON.
- Classify Windows and SSH failed login events.
- Calculate initial risk score.
- Add MITRE ATT&CK mapping.

Important output fields:

```text
timestamp
alert_id
agent_name
agent_ip
source_ip
rule_description
rule_id
rule_level
event_id
alert_type
risk_score
risk_level
mitre_tactic
mitre_technique
recommended_action
```

## 3. AbuseIPDB Check Node

Purpose:

- Enrich the source IP with reputation data.

Settings:

```text
Method: GET
URL: https://api.abuseipdb.com/api/v2/check
```

Query parameters:

```text
ipAddress = {{ $json.source_ip }}
maxAgeInDays = 90
```

Headers:

```text
Key = <ABUSEIPDB_API_KEY>
Accept = application/json
```

Returned enrichment fields:

```text
abuseConfidenceScore
totalReports
countryCode
isp
domain
lastReportedAt
```

Note: Private IPs such as `127.0.0.1` or `192.168.x.x` may return low or empty enrichment data. This is expected.

## 4. Format Telegram Alert Node

Purpose:

- Combine normalized Wazuh fields and AbuseIPDB results.
- Adjust risk score based on AbuseIPDB reputation.
- Build the final analyst message.

Telegram message format:

```text
SOC ALERT - High

Type: Windows Failed Login / Brute Force
Host: WIN-ENDPOINT-01
Agent IP: 192.168.86.140
Source IP: 127.0.0.1
Rule: Logon Failure - Unknown user or bad password
Rule ID: 60122
Event ID: 4625
Risk Score: 7/10
MITRE: T1110 - Brute Force

Threat Intel - AbuseIPDB
Abuse Score: 0
Total Reports: 4252
Country: N/A
ISP: N/A
Domain: N/A
Last Reported: 2026-05-24T18:47:33+00:00

Action: Investigate repeated Windows failed logins and validate the source.
Timestamp: 2026-05-24T18:58:32.398+0000
```

## 5. Telegram HTTP Request Node

Purpose:

- Send the formatted alert to Telegram.

Settings:

```text
Method: GET
URL: https://api.telegram.org/bot<TELEGRAM_BOT_TOKEN>/sendMessage
```

Query parameters:

```text
chat_id = <TELEGRAM_CHAT_ID>
text = {{ $json.telegram_text }}
```

## Test Commands

Test production webhook with Windows failed login:

```bash
curl -X POST http://localhost:5678/webhook/wazuh-alert \
  -H "Content-Type: application/json" \
  --data '{"timestamp":"2026-05-24T15:20:00+0000","rule":{"level":5,"description":"Logon Failure - Unknown user or bad password","id":"60122"},"agent":{"id":"001","name":"WIN-ENDPOINT-01","ip":"192.168.86.140"},"data":{"win":{"system":{"eventID":"4625"},"eventdata":{"ipAddress":"118.25.6.39"}}}}'
```

Test production webhook with SSH failed login:

```bash
curl -X POST http://localhost:5678/webhook/wazuh-alert \
  -H "Content-Type: application/json" \
  --data '{"timestamp":"2026-05-24T16:00:00+0000","rule":{"level":5,"description":"sshd: Attempt to login using a non-existent user","id":"5710"},"agent":{"id":"002","name":"KALI-ATTACKER","ip":"192.168.86.143"},"data":{"srcip":"192.168.86.146","srcuser":"fakeuser"},"full_log":"Failed password for invalid user fakeuser from 192.168.86.146 port 60436 ssh2"}'
```

## Exporting the Workflow

For GitHub evidence, export the real n8n workflow:

1. Open n8n.
2. Open `Wazuh Alert Intake`.
3. Click the workflow menu / three dots.
4. Choose export or download workflow.
5. Save it as:

```text
workflows/wazuh-alert-intake.json
```

Before uploading, make sure no real Telegram token or AbuseIPDB key is included.

