#!/bin/bash
set -e

CONFIG_DIR="/opt/rsdragonwilds/RSDragonwilds/Saved/Config/Linux"
CONFIG_FILE="${CONFIG_DIR}/DedicatedServer.ini"

# Create config directory if it doesn't exist
mkdir -p "${CONFIG_DIR}"

# Write DedicatedServer.ini from environment variables
cat > "${CONFIG_FILE}" <<EOF
[DedicatedServer]
OwnerID=${OWNER_ID}
ServerName=${SERVER_NAME:-My Dragonwilds Server}
DefaultWorldName=${DEFAULT_WORLD_NAME:-DefaultWorld}
AdminPassword=${ADMIN_PASSWORD}
WorldPassword=${WORLD_PASSWORD:-}
EOF

echo "=== DedicatedServer.ini ==="
cat "${CONFIG_FILE}"
echo "==========================="

# Launch the dedicated server
exec /opt/rsdragonwilds/RSDragonwilds.sh \
    -log \
    -port="${SERVER_PORT:-7777}" \
    "$@"
