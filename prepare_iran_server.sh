#!/bin/bash

# 1. Check for root privileges
if [ "$EUID" -ne 0 ]; then 
  echo "Error: Please run this script as root or with sudo."
  exit 1
fi

echo "--- Starting Docker Installation and Mirror Setup ---"

# 2. Replace all Ubuntu repo links with Runflare mirror
SOURCES_FILE="/etc/apt/sources.list.d/ubuntu.sources"

if [ -f "$SOURCES_FILE" ]; then
    echo "Updating Ubuntu source repositories in $SOURCES_FILE..."
    # Backup the original file
    cp "$SOURCES_FILE" "${SOURCES_FILE}.bak"
    
    # Using regex to find any http link ending in /ubuntu and replacing it
    # This targets the 'URIs: http://...' lines regardless of the subdomain
    sed -i 's|http://.*/ubuntu|http://mirror-linux.runflare.com/ubuntu|g' "$SOURCES_FILE"
    
    echo "Sources updated successfully."
else
    echo "Error: $SOURCES_FILE not found. Please ensure you are on a version of Ubuntu using DEB822 sources (like 24.04)."
    exit 1
fi

# 3. Update package list
echo "Running apt update..."
apt update -y

# 4. Install Docker and Docker Compose
echo "Installing Docker and Docker Compose (V2)..."
apt install -y docker.io docker-compose-v2

# 5. Configure Docker Daemon Mirror
echo "Configuring Docker registry mirror..."
mkdir -p /etc/docker
# Overwrite current content with the Runflare mirror
cat <<EOF > /etc/docker/daemon.json
{
  "registry-mirrors": ["https://mirror-docker.runflare.com"]
}
EOF

# 6. Restart Docker service to apply changes
echo "Restarting Docker service..."
systemctl restart docker

# 7. Verify installation
echo "Verifying Docker with hello-world..."
docker run hello-world

echo "--- Setup Completed Successfully! ---"
