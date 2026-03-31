# RuneScape: Dragonwilds — Dedicated Server (Docker)

A Docker image that runs a self-hosted **RuneScape: Dragonwilds** dedicated server using SteamCMD, based on the [official guide](https://www.reddit.com/r/RSDragonwilds/comments/1s7weoz/dedicated_servers_a_howto_guide/).

## Requirements

- Docker & Docker Compose
- UDP port **7777** forwarded through your firewall/router
- ~2 GB RAM + 1 GB per player (up to 6 players)

## Quick Start

1. **Create your `.env` file** from the example:

   ```bash
   cp .env.example .env
   ```

2. **Edit `.env`** with your values:

   | Variable | Required | Description |
   |---|---|---|
   | `OWNER_ID` | Yes | Your Player ID (found in-game under Settings) |
   | `SERVER_NAME` | Yes | Server name shown in the public list |
   | `DEFAULT_WORLD_NAME` | Yes | World name created on first boot |
   | `ADMIN_PASSWORD` | Yes | Password for the Server Management menu |
   | `WORLD_PASSWORD` | No | Set to restrict access; leave empty for public |
   | `SERVER_PORT` | No | UDP port (default `7777`) |

3. **Build and start** the server:

   ```bash
   docker compose up -d --build
   ```

4. **View logs:**

   ```bash
   docker compose logs -f
   ```

## Connecting

In-game, go to **Public** worlds and search for your exact **World Name** (case-sensitive).

## Managing Saves

Server save data is stored in the `server-data` Docker volume, mapped to:

```
/opt/rsdragonwilds/RSDragonwilds/Saved
```

### Upload a local world

1. Stop the server: `docker compose down`
2. Copy your `.sav` file into the volume's `Savegames/` directory.
3. Start the server: `docker compose up -d`

### Back up saves

```bash
docker cp rsdragonwilds-server:/opt/rsdragonwilds/RSDragonwilds/Saved/Savegames ./backups
```

## Updating

Rebuild the image to pull the latest server files from Steam:

```bash
docker compose down
docker compose build --no-cache
docker compose up -d
```

## Ports

| Port | Protocol | Purpose |
|---|---|---|
| 7777 | UDP | Game traffic (configurable via `SERVER_PORT`) |

Ensure this port is forwarded through your router and firewall for UDP traffic.
