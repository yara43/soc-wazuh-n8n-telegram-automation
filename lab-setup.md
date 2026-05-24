# Lab Setup

This document explains how the lab was built from scratch.

## 1. Virtualization

The lab was built using VMware Workstation.

Virtual machines:

- Ubuntu Server: SOC server.
- Windows 10: monitored endpoint.
- Kali Linux: attacker machine and monitored Linux endpoint.

Recommended resources:

| VM | CPU | RAM | Disk |
|---|---:|---:|---:|
| Ubuntu Server | 2-4 cores | 4-8 GB | 60-80 GB |
| Windows 10 | 2 cores | 4 GB | 50 GB |
| Kali Linux | 2 cores | 2-4 GB | 40-80 GB |

## 2. Network

All VMs were placed on the same VMware NAT network.

Observed lab IPs:

```text
Ubuntu Server: 192.168.86.146
Windows 10:    192.168.86.140
Kali Linux:    192.168.86.143
```

Connectivity checks:

```bash
ip -br a
ping -c 4 8.8.8.8
ping -c 4 192.168.86.140
ping -c 4 192.168.86.143
```

## 3. Ubuntu Server Preparation

Update the server:

```bash
sudo apt update
sudo apt upgrade -y
sudo apt install curl wget unzip net-tools openssh-server docker.io docker-compose-v2 -y
sudo systemctl enable --now ssh
sudo systemctl enable --now docker
```

Check SSH and Docker:

```bash
sudo systemctl status ssh
sudo systemctl status docker
```

## 4. Disk Space Issue and Fix

During the lab, Wazuh vulnerability feed data filled the Ubuntu disk. The issue was confirmed with:

```bash
df -h
sudo du -xhd1 /var/ossec | sort -h
sudo du -xhd1 /var/ossec/queue | sort -h
```

The largest directories were:

```text
/var/ossec/queue/vd
/var/ossec/queue/vd_updater
```

For this lab, the vulnerability feed cache was cleared:

```bash
sudo systemctl stop wazuh-manager
sudo find /var/ossec/queue/vd -mindepth 1 -delete
sudo find /var/ossec/queue/vd_updater -mindepth 1 -delete
df -h
```

After cleanup, the disk returned to a usable state.

## 5. Lab Evidence

Useful commands for documentation screenshots:

```bash
ip -br a
df -h
sudo /var/ossec/bin/agent_control -l
sudo docker ps
```

