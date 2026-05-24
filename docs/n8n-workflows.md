# n8n Workflow Documentation

## Workflow Name

```text
Wazuh Alert Intake
```

## Workflow Purpose

This workflow receives Wazuh alerts, normalizes nested Wazuh JSON fields, classifies the alert type, maps it to MITRE ATT&CK, enriches the source IP using AbuseIPDB, and sends a formatted Telegram notification.

## Workflow Nodes

```text
Webhook -> Normalize Wazuh Alert -> AbuseIPDB Check -> Format Telegram Alert -> Telegram HTTP Request
```

## Node 1: Webhook

| Setting | Value |
|---|---|
| HTTP Method | `POST` |
| Path | `wazuh-alert` |
| Test URL | `http://localhost:5678/webhook-test/wazuh-alert` |
| Production URL | `http://localhost:5678/webhook/wazuh-alert` |

The production URL is used by the Wazuh custom integration.

## Node 2: Normalize Wazuh Alert

Type: `Code`

Language: `JavaScript`

Purpose:

- Accept both simple test JSON and real Wazuh nested JSON.
- Extract agent name, agent IP, rule ID, event ID, source IP, timestamp, and rule description.
- Classify Windows failed login and SSH failed login events.
- Add MITRE ATT&CK mapping.
- Calculate a base risk score.

```js
const item = $input.first().json;
const raw = item.body || item || {};

const rule = raw.rule || {};
const agent = raw.agent || {};
const data = raw.data || {};
const win = data.win || {};
const winSystem = win.system || {};
const winEventData = win.eventdata || {};

const timestamp = raw.timestamp || new Date().toISOString();

const ruleLevel = Number(raw.rule_level ?? rule.level ?? 0);
const ruleDescription = raw.rule_description ?? rule.description ?? "No rule description";
const ruleId = String(raw.rule_id ?? rule.id ?? "unknown");

const agentName = raw.agent_name ?? agent.name ?? "unknown";
const agentIp = raw.agent_ip ?? agent.ip ?? "unknown";

const eventId = String(raw.event_id ?? winSystem.eventID ?? "unknown");

const fullLog = String(
  raw.full_log ??
  winSystem.message ??
  raw.message ??
  ""
);

let sourceIp =
  raw.source_ip ??
  raw.srcip ??
  winEventData.ipAddress ??
  data.srcip ??
  data.src_ip ??
  "unknown";

const textToClassify = `${ruleDescription} ${fullLog}`.toLowerCase();

let alertType = "Unknown/Suspicious Activity";
let mitreTactic = "Unknown";
let mitreTechnique = "Unknown";
let recommendedAction = "Review the alert details and investigate the affected host.";
let riskScore = ruleLevel;

if (textToClassify.includes("logon failure") || eventId === "4625") {
  alertType = "Windows Failed Login / Brute Force";
  mitreTactic = "Credential Access";
  mitreTechnique = "T1110 - Brute Force";
  recommendedAction = "Investigate repeated Windows failed logins and validate the source.";
  riskScore += 2;
} else if (
  textToClassify.includes("failed password") ||
  textToClassify.includes("authentication failed") ||
  textToClassify.includes("invalid user") ||
  textToClassify.includes("sshd")
) {
  alertType = "SSH Failed Login / Brute Force";
  mitreTactic = "Credential Access";
  mitreTechnique = "T1110 - Brute Force";
  recommendedAction = "Investigate repeated SSH failed logins and consider blocking the source IP.";
  riskScore += 2;
} else if (
  textToClassify.includes("nmap") ||
  textToClassify.includes("scan") ||
  textToClassify.includes("portsweep") ||
  textToClassify.includes("port scan")
) {
  alertType = "Port Scan";
  mitreTactic = "Discovery";
  mitreTechnique = "T1046 - Network Service Discovery";
  recommendedAction = "Investigate scanning activity and validate whether the source is authorized.";
  riskScore += 2;
} else if (
  textToClassify.includes("powershell") ||
  textToClassify.includes("encodedcommand") ||
  textToClassify.includes("executionpolicy bypass")
) {
  alertType = "Suspicious PowerShell";
  mitreTactic = "Execution";
  mitreTechnique = "T1059.001 - PowerShell";
  recommendedAction = "Review PowerShell command line, user context, and parent process.";
  riskScore += 3;
} else if (
  textToClassify.includes("eicar") ||
  textToClassify.includes("malware") ||
  textToClassify.includes("virus")
) {
  alertType = "Malware Detection";
  mitreTactic = "Execution";
  mitreTechnique = "T1204 - User Execution";
  recommendedAction = "Isolate the host if needed and investigate the detected file.";
  riskScore += 3;
} else if (
  textToClassify.includes("administrator") ||
  textToClassify.includes("admin group") ||
  eventId === "4720" ||
  eventId === "4732"
) {
  alertType = "Privilege Escalation / Account Change";
  mitreTactic = "Privilege Escalation";
  mitreTechnique = "T1136 - Create Account";
  recommendedAction = "Validate whether the account change was authorized.";
  riskScore += 3;
}

riskScore = Math.min(10, riskScore);

let riskLevel = "Low";
if (riskScore >= 9) riskLevel = "Critical";
else if (riskScore >= 7) riskLevel = "High";
else if (riskScore >= 4) riskLevel = "Medium";

return [
  {
    json: {
      timestamp,
      alert_id: raw.id || raw.alert_id || "unknown",
      agent_name: agentName,
      agent_ip: agentIp,
      source_ip: sourceIp,
      rule_description: ruleDescription,
      rule_id: ruleId,
      rule_level: ruleLevel,
      event_id: eventId,
      alert_type: alertType,
      risk_score: riskScore,
      risk_level: riskLevel,
      mitre_tactic: mitreTactic,
      mitre_technique: mitreTechnique,
      recommended_action: recommendedAction
    }
  }
];
```

## Node 3: AbuseIPDB Check

Type: `HTTP Request`

| Setting | Value |
|---|---|
| Method | `GET` |
| URL | `https://api.abuseipdb.com/api/v2/check` |
| Query parameter | `ipAddress={{ $json.source_ip }}` |
| Query parameter | `maxAgeInDays=90` |
| Header | `Key=<ABUSEIPDB_API_KEY>` |
| Header | `Accept=application/json` |

Private IPs such as `127.0.0.1` and `192.168.x.x` may return limited or no reputation data. That is normal.

## Node 4: Format Telegram Alert

Type: `Code`

Language: `JavaScript`

```js
const alert = $("Normalize Wazuh Alert").first().json;
const abuseResponse = $("AbuseIPDB Check").first().json;
const abuse = abuseResponse.data || {};

const abuseScore = abuse.abuseConfidenceScore ?? "N/A";
const totalReports = abuse.totalReports ?? "N/A";
const country = abuse.countryCode ?? "N/A";
const isp = abuse.isp ?? "N/A";
const domain = abuse.domain ?? "N/A";
const lastReported = abuse.lastReportedAt ?? "N/A";

let riskScore = Number(alert.risk_score || 0);

if (Number(abuseScore) >= 75) riskScore += 3;
else if (Number(abuseScore) >= 25) riskScore += 1;

riskScore = Math.min(10, riskScore);

let riskLevel = "Low";
if (riskScore >= 9) riskLevel = "Critical";
else if (riskScore >= 7) riskLevel = "High";
else if (riskScore >= 4) riskLevel = "Medium";

const telegramText =
`SOC ALERT - ${riskLevel}

Type: ${alert.alert_type}
Host: ${alert.agent_name}
Agent IP: ${alert.agent_ip}
Source IP: ${alert.source_ip}
Rule: ${alert.rule_description}
Rule ID: ${alert.rule_id}
Event ID: ${alert.event_id}
Risk Score: ${riskScore}/10
MITRE: ${alert.mitre_technique}

Threat Intel - AbuseIPDB
Abuse Score: ${abuseScore}
Total Reports: ${totalReports}
Country: ${country}
ISP: ${isp}
Domain: ${domain}
Last Reported: ${lastReported}

Action: ${alert.recommended_action}
Timestamp: ${alert.timestamp}`;

return [
  {
    json: {
      ...alert,
      risk_score: riskScore,
      risk_level: riskLevel,
      abuse_score: abuseScore,
      total_reports: totalReports,
      country,
      isp,
      domain,
      last_reported: lastReported,
      telegram_text: telegramText
    }
  }
];
```

## Node 5: Telegram HTTP Request

Type: `HTTP Request`

| Setting | Value |
|---|---|
| Method | `GET` |
| URL | `https://api.telegram.org/bot<TELEGRAM_BOT_TOKEN>/sendMessage` |
| Query parameter | `chat_id=<TELEGRAM_CHAT_ID>` |
| Query parameter | `text={{ $json.telegram_text }}` |

## Publish Workflow

After testing, publish the workflow with a version name such as:

```text
AbuseIPDB enrichment added
```

Description:

```text
Added AbuseIPDB threat intelligence enrichment to include IP reputation, reports, country, ISP, and domain in Telegram alerts.
```

