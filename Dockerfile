# Stage 1: Install the dedicated server via SteamCMD
FROM --platform=linux/amd64 steamcmd/steamcmd:ubuntu-24 AS builder

RUN steamcmd +force_install_dir /opt/rsdragonwilds \
    +login anonymous \
    +app_update 4019830 validate \
    +quit

# Stage 2: Runtime image
FROM --platform=linux/amd64 ubuntu:24.04

RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        lib32stdc++6 \
        lib32gcc-s1 \
        libsdl2-2.0-0 \
        ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Create a non-root user to run the server
RUN useradd -m -d /home/steam -s /bin/bash steam

# Copy installed server files from builder
COPY --from=builder /opt/rsdragonwilds /opt/rsdragonwilds

# Set ownership
RUN chown -R steam:steam /opt/rsdragonwilds

# Expose default game port (UDP)
EXPOSE 7777/udp

# Volumes for persistent data (saves, config, logs)
VOLUME ["/opt/rsdragonwilds/RSDragonwilds/Saved"]

# Copy entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

USER steam
WORKDIR /opt/rsdragonwilds

ENTRYPOINT ["/entrypoint.sh"]
