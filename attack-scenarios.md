# Attack Simulation Scenarios

## Scenario 1: Windows Failed Login

Objective:

Detect failed Windows login attempts and send a Telegram SOC alert.

Machine:

```text
Target: Windows 10 endpoint
Agent: WIN-ENDPOINT-01
```

Steps:

1. Open or lock the Windows VM.
2. Attempt to log in with the wrong password several times.
3. Wait for Wazuh to receive the Windows Security Event.
4. Confirm the alert in Wazuh logs.
5. Confirm n8n workflow execution.
6. Confirm Telegram alert.

Wazuh verification command:

```bash
sudo grep -i "Logon Failure" /var/ossec/logs/alerts/alerts.json | tail -n 1
```

Expected Wazuh fields:

```text
Rule ID: 60122
Rule description: Logon Failure - Unknown user or bad password
Event ID: 4625
Agent: WIN-ENDPOINT-01
```

Expected Telegram alert:

```text
SOC ALERT - High
Type: Windows Failed Login / Brute Force
Host: WIN-ENDPOINT-01
MITRE: T1110 - Brute Force
```

## Scenario 2: Kali SSH Failed Login

Objective:

Detect SSH authentication failure on Kali and send a Telegram SOC alert.

Machine:

```text
Target: Kali Linux
Agent: KALI-ATTACKER
```

From Ubuntu Server:

```bash
ssh fakeuser@192.168.86.143
```

Enter a wrong password several times.

Wazuh verification command:

```bash
sudo grep -i "Failed password\|Invalid user\|sshd" /var/ossec/logs/alerts/alerts.json | tail -n 3
```

Expected Wazuh fields:

```text
Rule ID: 5710
Rule description: sshd: Attempt to login using a non-existent user
Agent: KALI-ATTACKER
Source IP: 192.168.86.146
```

Expected Telegram alert:

```text
SOC ALERT - High
Type: SSH Failed Login / Brute Force
Host: KALI-ATTACKER
MITRE: T1110 - Brute Force
```

## Scenario 3: Manual Enrichment Test

Objective:

Prove that n8n enrichment and Telegram notification work even before a real endpoint alert is generated.

Command:

```bash
curl -X POST http://localhost:5678/webhook/wazuh-alert \
  -H "Content-Type: application/json" \
  --data '{"timestamp":"2026-05-24T15:20:00+0000","rule":{"level":5,"description":"Logon Failure - Unknown user or bad password","id":"60122"},"agent":{"id":"001","name":"WIN-ENDPOINT-01","ip":"192.168.86.140"},"data":{"win":{"system":{"eventID":"4625"},"eventdata":{"ipAddress":"118.25.6.39"}}}}'
```

Expected result:

- n8n workflow starts.
- AbuseIPDB returns IP reputation.
- Telegram receives an enriched SOC alert.

