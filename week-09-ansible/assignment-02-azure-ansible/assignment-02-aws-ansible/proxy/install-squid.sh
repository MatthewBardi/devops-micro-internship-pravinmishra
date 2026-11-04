
#!/usr/bin/env bash
set -euo pipefail

# Install Squid on app1
sudo apt-get update
sudo apt-get install -y squid

# The approved squid.conf must already be copied
# into /tmp/squid.conf on app1.
test -f /tmp/squid.conf

# Validate before replacing the active configuration
sudo squid -k parse -f /tmp/squid.conf

# Install the approved configuration
sudo install -m 644 /tmp/squid.conf /etc/squid/squid.conf

# Enable and restart Squid
sudo systemctl enable squid
sudo systemctl restart squid

# Show service status
sudo systemctl is-active squid
