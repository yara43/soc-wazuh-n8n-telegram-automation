# Wazuh Installation and Configuration

## 1. Install Wazuh All-in-One

The Wazuh all-in-one installation was used on Ubuntu Server.

Download the installer:

```bash
wget -O wazuh-install.sh https://packages.wazuh.com/4.12/wazuh-install.sh
```

Run the installer:

```bash
sudo bash wazuh-install.sh -a -i
```

The installer creates:

- Wazuh manager
- Wazuh indexer
- Wazuh dashboard
- Filebeat integration
- Dashboard credentials

Important: Save the generated dashboard username and password securely. Do not commit them to GitHub.

## 2. Wazuh Services

Check service status:

```bash
sudo systemctl status wazuh-manager --no-pager
sudo systemctl status wazuh-indexer --no-pager
sudo systemctl status wazuh-dashboard --no-pager
```

Check all Wazuh processes:

```bash
sudo /var/ossec/bin/wazuh-control status
```

## 3. Dashboard Access

Dashboard URL:

```text
https://192.168.86.146
```

If the dashboard says `Wazuh dashboard server is not ready yet`, check the indexer:

```bash
curl -k https://127.0.0.1:9200
sudo systemctl status wazuh-indexer --no-pager
sudo journalctl -u wazuh-dashboard --no-pager -n 80
```

If OpenSearch security is not initialized:

```bash
sudo /usr/share/wazuh-indexer/bin/indexer-security-init.sh
sudo systemctl restart wazuh-dashboard
```

## 4. Windows Agent

The Windows endpoint was added as:

```text
Agent name: WIN-ENDPOINT-01
Agent IP:   192.168.86.140
Agent ID:   001
```

PowerShell was opened as Administrator on Windows.

Download and install Wazuh agent:

```powershell
$u="https://packages.wazuh.com/4.x/windows/wazuh-agent-4.12.0-1.msi"
$o="$env:TEMP\wazuh-agent.msi"
Invoke-WebRequest -Uri $u -OutFile $o
Start-Process msiexec.exe -Wait -ArgumentList "/i",$o,"/qn","WAZUH_MANAGER=192.168.86.146","WAZUH_AGENT_NAME=WIN-ENDPOINT-01"
Start-Service WazuhSvc
Get-Service WazuhSvc
```

Expected result:

```text
Status: Running
Name: WazuhSvc
DisplayName: Wazuh
```

## 5. Kali Agent

The Kali endpoint was added as:

```text
Agent name: KALI-ATTACKER
Agent IP:   192.168.86.143
Agent ID:   002
```

On Kali:

```bash
wget https://packages.wazuh.com/4.x/apt/pool/main/w/wazuh-agent/wazuh-agent_4.12.0-1_amd64.deb
sudo WAZUH_MANAGER="192.168.86.146" WAZUH_AGENT_NAME="KALI-ATTACKER" dpkg -i ./wazuh-agent_4.12.0-1_amd64.deb
sudo systemctl daemon-reload
sudo systemctl enable --now wazuh-agent
sudo systemctl status wazuh-agent
```

## 6. Verify Agents

On Ubuntu Server:

```bash
sudo /var/ossec/bin/agent_control -l
```

Expected result:

```text
ID: 001, Name: WIN-ENDPOINT-01, Active
ID: 002, Name: KALI-ATTACKER, Active
```

## 7. Custom Wazuh Integration to n8n

The custom integration script forwards selected failed-login alerts to n8n.

Script path:

```text
/var/ossec/integrations/custom-n8n
```

See [configs/custom-n8n.sh](configs/custom-n8n.sh).

Permissions:

```bash
sudo chown root:wazuh /var/ossec/integrations/custom-n8n
sudo chmod 750 /var/ossec/integrations/custom-n8n
```

Wazuh configuration snippet:

```xml
<integration>
  <name>custom-n8n</name>
  <level>5</level>
  <alert_format>json</alert_format>
</integration>
```

Validate and restart:

```bash
sudo /var/ossec/bin/wazuh-analysisd -t
sudo systemctl restart wazuh-manager
```

Check integration activity:

```bash
sudo cat /tmp/custom-n8n.log | tail -n 30
```

