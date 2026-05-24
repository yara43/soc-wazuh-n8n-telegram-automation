# Attack Scenarios

## Scenario 1: Windows Failed Login

### Objective

Generate failed Windows login events and confirm the full alert chain:

```text
Windows -> Wazuh -> n8n -> AbuseIPDB -> Telegram
```

### Steps

1. Start Windows VM.
2. Make sure Wazuh agent is running:

```powershell
Get-Service WazuhSvc
```

3. Lock Windows or go to the login screen.
4. Type the wrong password multiple times.
5. Wait for Wazuh to receive the alert.

### Evidence Command

On Ubuntu Server:

```bash
sudo grep -i "Logon Failure" /var/ossec/logs/alerts/alerts.json | tail -n 1
```

Expected fields:

```text
Event ID: 4625
Rule ID: 60122
Agent: WIN-ENDPOINT-01
Rule: Logon Failure - Unknown user or bad password
```

### Expected Telegram Alert

```text
SOC ALERT - High
Type: Windows Failed Login / Brute Force
Host: WIN-ENDPOINT-01
Event ID: 4625
MITRE: T1110 - Brute Force
```

## Scenario 2: Kali SSH Failed Login

### Objective

Generate SSH authentication failures against the Kali machine and send the alert to Telegram.

### Steps

From Ubuntu Server:

```bash
ssh fakeuser@192.168.86.143
```

Type a wrong password several times.

### Evidence Command

```bash
sudo grep -i "Failed password\|Invalid user\|sshd" /var/ossec/logs/alerts/alerts.json | tail -n 3
```

Expected fields:

```text
Agent: KALI-ATTACKER
Rule ID: 5710
Rule: sshd: Attempt to login using a non-existent user
Source IP: 192.168.86.146
MITRE: T1110 - Brute Force
```

### Expected Telegram Alert

```text
SOC ALERT - High
Type: SSH Failed Login / Brute Force
Host: KALI-ATTACKER
Rule ID: 5710
MITRE: T1110 - Brute Force
```

## Scenario 3: Simulated Public IP Enrichment Test

### Objective

Test AbuseIPDB enrichment with a public IP address.

### Command

```bash
curl -X POST http://localhost:5678/webhook/wazuh-alert \
  -H "Content-Type: application/json" \
  --data '{"timestamp":"2026-05-24T15:20:00+0000","rule":{"level":5,"description":"Logon Failure - Unknown user or bad password","id":"60122"},"agent":{"id":"001","name":"WIN-ENDPOINT-01","ip":"192.168.86.140"},"data":{"win":{"system":{"eventID":"4625"},"eventdata":{"ipAddress":"118.25.6.39"}}}}'
```

### Expected Result

Telegram alert includes AbuseIPDB details such as:

```text
Abuse Score
Total Reports
Country
ISP
Domain
Last Reported
```

