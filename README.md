# ttyd_connect

Docker and Kubernetes packaging for [ttyd](https://github.com/tsl0922/ttyd): a browser-based terminal with an SSH client, env-based login, and optional TLS.

**Private SSH keys are mounted at run time. They are not baked into the image and must not be committed.**

---

## Features

- Web terminal (ttyd) on port **7681**
- OpenSSH client with configurable `host_config`
- Web login via `USERNAME` / `PASSWORD` env vars
- Optional TLS (`/ssl/tls.crt`, `/ssl/tls.key`)
- Helper: `ssh-to-host`
- Tools: vim, nano, git, htop, curl, wget, rsync

---

## Quick start (Docker Compose)

1. Copy and edit SSH config:

```bash
cp host_config.example host_config
```

2. Place your private key beside the repo (local only, gitignored):

```bash
cp ~/.ssh/id_ed25519 ./key.pem
chmod 600 key.pem
```

3. Build and run:

```bash
docker compose up -d --build
```

4. Open http://localhost:7681 (default web login: `admin` / `changeme`; change before any real use).

Override key path:

```bash
SSH_KEY_PATH=/path/to/key.pem docker compose up -d
```

---

## Docker (manual)

```bash
./build.sh

docker run -d --name ttyd_connect \
  -p 7681:7681 \
  -e USERNAME=admin \
  -e PASSWORD=changeme \
  -v "$(pwd)/host_config:/root/.ssh/config:ro" \
  -v "$(pwd)/key.pem:/root/.ssh/key.pem:ro" \
  ttyd_connect:latest
```

---

## Kubernetes

Manifest: `k8s/ttyd-connect.yaml` (Namespace, ConfigMap with `host_config`, Deployment, NodePort Service).

Create the SSH key secret (do not commit keys):

```bash
kubectl create namespace ttyd-connect
kubectl create secret generic ttyd-ssh-key \
  --from-file=key.pem=./key.pem \
  -n ttyd-connect
kubectl apply -f k8s/ttyd-connect.yaml
```

NodePort default: **30781** -> container **7681**.

---

## SSH config

| Path | Source |
|------|--------|
| `/root/.ssh/key.pem` | Bind-mount or K8s Secret |
| `/root/.ssh/config` | `host_config` in repo or ConfigMap |

Example (`host_config.example`):

```
Host dev-server
    HostName dev.example.com
    User ubuntu
    IdentityFile ~/.ssh/key.pem
    Port 22
```

Inside the container:

```bash
ssh dev-server
ssh-to-host user@host
```

---

## Environment variables

| Variable | Default | Purpose |
|----------|---------|---------|
| `USERNAME` | `admin` | Web terminal username |
| `PASSWORD` | `changeme` | Web terminal password |
| `TTYD_OPTIONS` | (empty) | Extra ttyd CLI flags |
| `PASSWORD_HASH` | (derived) | Set directly to skip hashing |

---

## Security

- Dev defaults only. Change `USERNAME` / `PASSWORD` for anything beyond local testing.
- Never commit `key.pem` or real `host_config` with production hosts.
- Prefer TLS for non-local access.
- Image runs as root with passwordless SSH key access when a key is mounted.

---

## Layout

```
.
├── Dockerfile
├── entrypoint.sh
├── build.sh
├── host_config.example
├── host_config
├── docker-compose.yml
├── k8s/ttyd-connect.yaml
└── LICENSE
```

---

## License

MIT - see [LICENSE](LICENSE).

## Credits

- [ttyd](https://github.com/tsl0922/ttyd) by tsl0922
