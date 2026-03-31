#!/usr/bin/env bash
# ============================================================
# Oracle Cloud ARM VM — Dragonwilds Dedicated Server Bootstrap
# ============================================================
# Run as root (or via cloud-init user-data) on a fresh
# Ubuntu 22.04/24.04 aarch64 instance.
#
# Usage:
#   chmod +x init.sh
#   sudo ./init.sh
# ============================================================
set -euo pipefail

REPO_URL="https://github.com/gord5500/dragonwilds.git"
INSTALL_DIR="/opt/dragonwilds"

echo ">>> Updating system packages"
apt-get update && apt-get upgrade -y

# ── Docker ───────────────────────────────────────────────────
if ! command -v docker &>/dev/null; then
    echo ">>> Installing Docker"
    apt-get install -y ca-certificates curl gnupg
    install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
        | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    chmod a+r /etc/apt/keyrings/docker.gpg

    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
      https://download.docker.com/linux/ubuntu \
      $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
      > /etc/apt/sources.list.d/docker.list

    apt-get update
    apt-get install -y docker-ce docker-ce-cli containerd.io \
        docker-buildx-plugin docker-compose-plugin
fi

# ── QEMU user-mode emulation (run x86_64 containers on ARM) ─
echo ">>> Enabling QEMU x86_64 emulation for Docker"
docker run --rm --privileged multiarch/qemu-user-static --reset -p yes

# ── Git ──────────────────────────────────────────────────────
if ! command -v git &>/dev/null; then
    echo ">>> Installing Git"
    apt-get install -y git
fi

# ── Clone / pull repo ───────────────────────────────────────
if [ -d "${INSTALL_DIR}/.git" ]; then
    echo ">>> Repo already cloned — pulling latest"
    git -C "${INSTALL_DIR}" pull
else
    echo ">>> Cloning repo to ${INSTALL_DIR}"
    git clone "${REPO_URL}" "${INSTALL_DIR}"
fi

cd "${INSTALL_DIR}"

# ── .env setup ───────────────────────────────────────────────
if [ ! -f .env ]; then
    echo ">>> Creating .env from template"
    cp .env.example .env
    echo ""
    echo "╔══════════════════════════════════════════════════════╗"
    echo "║  IMPORTANT: Edit ${INSTALL_DIR}/.env before starting ║"
    echo "║  At minimum set OWNER_ID and ADMIN_PASSWORD          ║"
    echo "╚══════════════════════════════════════════════════════╝"
    echo ""
fi

# ── Firewall (iptables — Oracle Cloud uses iptables by default) ──
echo ">>> Opening UDP port 7777"
iptables -I INPUT -p udp --dport 7777 -j ACCEPT
# Persist the rule across reboots
if command -v netfilter-persistent &>/dev/null; then
    netfilter-persistent save
else
    apt-get install -y iptables-persistent
    netfilter-persistent save
fi

# ── Build & Start ────────────────────────────────────────────
echo ">>> Building and starting the Dragonwilds server"
docker compose up -d --build

echo ""
echo "=== Setup complete ==="
echo "Container status:"
docker compose ps
echo ""
echo "View logs:  cd ${INSTALL_DIR} && docker compose logs -f"
echo "Stop:       cd ${INSTALL_DIR} && docker compose down"
echo ""
echo "REMINDER: You must also add an ingress rule for UDP 7777"
echo "in your Oracle Cloud VCN Security List / Network Security Group."
