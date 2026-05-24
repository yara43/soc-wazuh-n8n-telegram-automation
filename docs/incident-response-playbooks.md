# Incident Response Playbooks

## Playbook 1: Windows Failed Login / Brute Force

### Trigger

Wazuh alert contains:

```text
Event ID: 4625
Rule: Logon Failure - Unknown user or bad password
```

### MITRE ATT&CK

```text
Tactic: Credential Access
Technique: T1110 - Brute Force
```

### Triage Steps

1. Confirm affected endpoint.
2. Check username targeted.
3. Check source IP.
4. Review repeated failed login count.
5. Check if a successful login happened after failures.
6. Enrich source IP with AbuseIPDB.

### Recommended Response

- If source is internal, identify the machine and user.
- If source is external or suspicious, block it after validation.
- Reset the targeted account password if compromise is suspected.
- Enable account lockout policy if not already configured.

## Playbook 2: SSH Failed Login / Brute Force

### Trigger

Wazuh alert contains:

```text
Failed password
Invalid user
sshd
```

### MITRE ATT&CK

```text
Tactic: Credential Access
Technique: T1110 - Brute Force
```

### Triage Steps

1. Confirm target host.
2. Confirm source IP.
3. Check whether the username exists.
4. Check number of attempts.
5. Review whether a successful login followed.
6. Review AbuseIPDB reputation.

### Recommended Response

- Disable password SSH login if possible.
- Use SSH keys.
- Add rate limiting or fail2ban.
- Block malicious IPs after analyst approval.

## Playbook 3: Port Scan

### Trigger

Alerts mentioning:

```text
nmap
scan
port scan
portsweep
```

### MITRE ATT&CK

```text
Tactic: Discovery
Technique: T1046 - Network Service Discovery
```

### Recommended Response

- Confirm whether scanning is authorized.
- Identify source system owner.
- Check firewall logs.
- Block source if unauthorized and hostile.

## Playbook 4: Suspicious PowerShell

### Trigger

Alerts mentioning:

```text
PowerShell
EncodedCommand
ExecutionPolicy Bypass
DownloadString
```

### MITRE ATT&CK

```text
Tactic: Execution
Technique: T1059.001 - PowerShell
```

### Recommended Response

- Review command line.
- Check parent process.
- Check user context.
- Collect script block logs.
- Isolate endpoint if malicious execution is confirmed.

