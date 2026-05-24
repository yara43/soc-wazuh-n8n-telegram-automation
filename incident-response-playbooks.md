# Incident Response Playbooks

## Playbook 1: Windows Failed Login / Brute Force

Trigger:

```text
Windows Event ID 4625
Wazuh rule: Logon Failure - Unknown user or bad password
```

MITRE ATT&CK:

```text
Tactic: Credential Access
Technique: T1110 - Brute Force
```

Triage steps:

1. Confirm the affected endpoint name and IP address.
2. Check the target username.
3. Review the number of failed attempts.
4. Check whether the source IP is local or external.
5. Review AbuseIPDB reputation results.
6. Validate whether the activity is expected user behavior or suspicious.

Recommended response:

- If internal and low-volume: validate with the user.
- If repeated or suspicious: reset password and monitor the account.
- If external or high-confidence malicious: block the source IP after approval.
- Document the timeline and final decision.

## Playbook 2: SSH Failed Login / Brute Force

Trigger:

```text
sshd failed password
invalid user
Wazuh rule 5710
```

MITRE ATT&CK:

```text
Tactic: Credential Access
Technique: T1110 - Brute Force
```

Triage steps:

1. Confirm the affected Linux host.
2. Identify the source IP.
3. Check the username attempted.
4. Review frequency of failed login attempts.
5. Review AbuseIPDB reputation.
6. Check whether SSH should be exposed to that source.

Recommended response:

- Disable password-based SSH if not required.
- Use strong authentication and key-based login.
- Block suspicious source IPs after approval.
- Review `/var/log/auth.log` or journald for additional attempts.

## Playbook 3: Threat Intelligence Review

Trigger:

```text
AbuseIPDB score above 25
Multiple reports
External source IP
```

Triage steps:

1. Review abuse confidence score.
2. Review report count.
3. Review country and ISP.
4. Compare against known business locations.
5. Decide whether blocking is justified.

Response levels:

| Risk | Condition | Response |
|---|---|---|
| Low | Internal/private IP or no reputation | Monitor |
| Medium | Some reports or repeated failures | Investigate |
| High | Multiple failed attempts and suspicious IP | Escalate |
| Critical | High abuse score and repeated attack | Block after approval |

