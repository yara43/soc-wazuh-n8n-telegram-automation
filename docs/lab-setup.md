# Lab Setup Guide

## 1. Virtual Machines

The lab was built using VMware with three main virtual machines:

| VM | Purpose |
|---|---|
| Ubuntu Server | Hosts Wazuh Manager, Wazuh Dashboard, Wazuh Indexer, and n8n |
| Windows 10 | Monitored endpoint |
| Kali Linux | Monitored Linux endpoint and attack simulation machine |

## 2. Network Design

All machines were placed on the same VMware NAT network so they can communicate with each other.

Final IP addresses:

```text
Ubuntu Server:  192.168.86.146
Windows 10:     192.168.86.140
Kali Linux:     192.168.86.143
```

Useful commands:

```bash
ip a
ip -br a
ping -c 4 8.8.8.8
ping -c 4 google.com
```

On Windows PowerShell:

```powershell
ipconfig
ping 192.168.86.146
```

## 3. Ubuntu Server Preparation

After installing Ubuntu Server, update packages:

```bash
sudo apt update
sudo apt upgrade -y
```

Install useful tools:

```bash
sudo apt install curl wget unzip net-tools openssh-server -y
sudo systemctl enable --now ssh
```

Verify SSH:

```bash
sudo systemctl status ssh
```

## 4. Wazuh Server

Wazuh Manager, Wazuh Indexer, and Wazuh Dashboard were installed on Ubuntu Server.

Main services:

```bash
sudo systemctl status wazuh-manager
sudo systemctl status wazuh-indexer
sudo systemctl status wazuh-dashboard
```

The dashboard is accessed at:

```text
https://192.168.86.146
```

## 5. Windows Agent

Windows was connected to Wazuh as:

```text
Agent name: WIN-ENDPOINT-01
Agent IP: 192.168.86.140
Agent ID: 001
```

The Wazuh agent service was verified from Windows PowerShell:

```powershell
Get-Service WazuhSvc
```

Expected status:

```text
Running
```

## 6. Kali Agent

Kali Linux was connected to Wazuh as:

```text
Agent name: KALI-ATTACKER
Agent IP: 192.168.86.143
Agent ID: 002
```

Kali agent status:

```bash
sudo systemctl status wazuh-agent
```

Expected status:

```text
active (running)
```

## 7. Verify Agents from Wazuh Manager

On Ubuntu Server:

```bash
sudo /var/ossec/bin/agent_control -l
```

Expected output:

```text
ID: 000, Name: socadmin (server), IP: 127.0.0.1, Active/Local
ID: 001, Name: WIN-ENDPOINT-01, IP: any, Active
ID: 002, Name: KALI-ATTACKER, IP: any, Active
```

## 8. n8n Installation

n8n was installed using Docker.

```bash
sudo apt install docker.io docker-compose-v2 -y
sudo systemctl enable --now docker
sudo docker volume create n8n_data
sudo docker run -d --name n8n --restart unless-stopped -p 5678:5678 -e N8N_SECURE_COOKIE=false -v n8n_data:/home/node/.n8n n8nio/n8n
```

Verify:

```bash
sudo docker ps
```

Access n8n:

```text
http://192.168.86.146:5678
```

