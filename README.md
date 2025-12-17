# Wakey Wakey, Eggs and Claudey 🐱☕

Wake up Claude and start counting 5h usage reset.

## Requirements

The project goal is to wake up Claude and start counting token usage at 5 AM every day, with the first reset at around 10 AM after 5 hours, maximizing usage during work hours.

**Deployment Methods:**

1. Create a simple Docker Image and run it on K8s using CronJob
2. Set up Linux/macOS crontab to run automatically

---

## 🚀 Getting Started

### Method I. Kubernetes CronJob

```bash
# 1. get OAuth token from Claude CLI
claude setup-token
# copy the token output

# 2. create Kubernetes secret with token (one-time setup)
kubectl create secret generic claude-token \
  --from-literal=CLAUDE_CODE_OAUTH_TOKEN="paste_your_token_here" \
  --namespace=default

# 3. apply Kubernetes configs
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/cronjob.yaml
```

### Method II: Linux Crontab

```bash
# 1. install Claude CLI (if not already installed)
curl -fsSL https://claude.ai/install.sh | bash

# 2. setup credentials
# follow the prompts to authenticate

# 3. run setup script
chmod +x setup-crontab.sh
./setup-crontab.sh

# 4. check logs
tail -f ~/wakey-wakey-claude.log
```

### Method III: GitHub Action Crontab

1. Fork this project
2. Set up GitHub secret:
   - Go to Settings > Secrets and variables > Actions
   - Click "New repository secret"
   - Name: `CLAUDE_CODE_OAUTH_TOKEN`
   - Value: Your OAuth token (obtain from `claude setup-token`)
3. The workflow will automatically run at 5 AM UTC+8 daily to wake Claude.


## Build Your Own Docker Image

```
# build Docker image
docker build -t ghcr.io/xiaoxiaosn/wakey-wakey-claude:latest

# test Docker image
docker run --rm \
  --env-file .env \
  -v $(pwd)/claude.json:/root/.claude.json \
  ghcr.io/xiaoxiaosn/wakey-wakey-claude:latest
```

---

## Claude CLI

### minimal token usage

```bash
claude -p --model haiku --max-turns 1 "reply hi only"
```
