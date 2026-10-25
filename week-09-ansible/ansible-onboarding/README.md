
# Ansible Development Workstation Onboarding

## Project Overview

This project documents the setup of a reproducible Ansible development workstation for DevOps Micro Internship (DMI) Cohort 3 — Week 09, Assignment 01.

The goal is to provide a consistent, secure, and team-friendly development environment for creating, testing, and maintaining Ansible automation.

## Workstation Details

| Component | Configuration |
|---|---|
| Host operating system | Windows with WSL2 |
| Linux distribution | Ubuntu 26.04 LTS |
| Python | 3.14.4 |
| Ansible | 14.5.0 |
| Ansible Core | 2.21.5 |
| ansible-lint | 26.10.1 |
| yamllint | 1.38.0 |
| pre-commit | 4.7.0 |
| Git | 2.53.0 |
| Default Git branch | main |
| IDE | Visual Studio Code with WSL integration |
| SSH key type | Ed25519 |

## Project Structure

```text
ansible-onboarding/
├── .vscode/
│   └── settings.json
├── .editorconfig
├── .gitignore
├── .pre-commit-config.yaml
├── ansible.cfg
├── README.md
└── requirements.txt
```

The `.venv/` directory is created locally but excluded from Git.

## Python Environment Setup

Create an isolated Python environment:

```bash
python3 -m venv .venv
source .venv/bin/activate
```

Install the project dependencies:

```bash
python -m pip install -r requirements.txt
```

Verify the tools:

```bash
ansible --version
ansible-lint --version
yamllint --version
pre-commit --version
```

## VS Code Development Standards

The following extensions are required:

- Ansible by Red Hat
- YAML by Red Hat
- Python by Microsoft
- WSL by Microsoft for Windows-based workstations

Workspace standards are defined in:

- `.vscode/settings.json` for Python interpreter selection, editor formatting, and Ansible validation.
- `.editorconfig` for consistent indentation, line endings, and character encoding.

## Ansible Configuration

The project uses `ansible.cfg` for shared defaults, including SSH connection settings, inventory location, remote username, and host key verification.

Verify Ansible recognizes the configuration:

```bash
ansible --version
ansible-config dump --only-changed
```

SSH host key checking remains enabled to prevent automatically trusting unknown servers.

## SSH Configuration

An existing Ed25519 SSH key is used for authentication.

Start the SSH agent and load the key:

```bash
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
ssh-add -l
```

Secure SSH configuration permissions:

```bash
chmod 600 ~/.ssh/config
```

Never commit SSH private keys, credentials, or other secrets to Git.

## Git and Pre-commit Checks

Configure the default Git branch:

```bash
git config --global init.defaultBranch main
```

Install the Git hooks:

```bash
pre-commit install
```

Run the project validation checks:

```bash
pre-commit run --all-files
```

The project uses yamllint and ansible-lint hooks. Both checks passed during workstation setup.

## New Machine? Do This

- [ ]  Install Git and Visual Studio Code.
- [ ]  Install WSL2 and Ubuntu if using Windows.
- [ ]  Install Python, pip, and the Python virtual environment package.
- [ ]  Clone the approved project repository.
- [ ]  Open the project in VS Code using WSL.
- [ ]  Install the Ansible, YAML, and Python VS Code extensions.
- [ ]  Create `.venv` using `python3 -m venv .venv`.
- [ ]  Activate `.venv` and install packages from `requirements.txt`.
- [ ]  Verify `ansible.cfg` and the project editor settings.
- [ ]  Configure an Ed25519 SSH key and SSH agent securely.
- [ ]  Configure Git identity and install pre-commit hooks.
- [ ]  Run `pre-commit run --all-files` and confirm the checks pass.

## Team-Friendly Practice

The project uses an isolated Python virtual environment and versioned configuration files. This makes the development environment easier to reproduce across team members' workstations and reduces differences between individual setups.

## Pitfall Avoided

Installing Python packages globally was avoided by using `.venv`. This prevents project dependencies from interfering with system Python packages or other development projects.

The SSH agent was also explicitly initialized and verified before use.

## Corporate Proxy and CA Certificates

No corporate proxy or custom CA certificate configuration was required during this setup. If a future workstation uses a corporate proxy, its approved proxy and CA certificate settings should be configured according to the organization's security standards.

## Security Notes

- Never commit `.venv`, SSH private keys, passwords, tokens, or secrets.
- Keep SSH host key verification enabled.
- Review staged files before committing.
- Run linting checks before submitting changes.
- Use approved credentials and least-privilege access for automation.
```
