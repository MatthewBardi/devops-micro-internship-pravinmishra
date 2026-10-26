
# Assignment 02 — Ansible Ad-Hoc Commands

Run these commands from Ubuntu WSL after deploying the four Azure VMs and configuring inventory.ini.

## 1. Verify Ansible connectivity

```bash
ansible all -i inventory.ini -m ping
```

## 2. Check the remote username

```bash
ansible all -i inventory.ini -m command -a "whoami"
```

## 3. Check uptime on all four VMs

```bash
ansible all -i inventory.ini -m command -a "uptime"
```

## 4. Install Nginx on the web servers

```bash
ansible web -i inventory.ini -b -m apt -a "name=nginx state=present update_cache=yes"
```

## 5. Start and enable Nginx

```bash
ansible web -i inventory.ini -b -m service -a "name=nginx state=started enabled=yes"
```

## 6. Install htop on all VMs

```bash
ansible all -i inventory.ini -b -m apt -a "name=htop state=present update_cache=yes"
```

## 7. Check disk usage on the database VM

```bash
ansible db -i inventory.ini -m command -a "df -h"
```

## 8. Check memory usage on all VMs

```bash
ansible all -i inventory.ini -m command -a "free -m"
```
