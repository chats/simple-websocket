# Simple Websocket
### Redis-Enabled WebSocket + Webhook Server

This is a lightweight WebSocket + Webhook server and optionally using Redis for message broadcasting across multiple instances.

---

### Features
- 🔌 WebSocket server with API key auth (via query param)
- 📥 HTTP Webhook endpoint
- 🔁 Optional Redis Pub/Sub support

---
#### Environment
```
PORT=3000
API_KEY=supersecretapikey
USE_REDIS=true
REDIS_URL=redis://redis:6379
WEBSOCKET_PATH=/ws
WEBHOOK_PATH=/webhook```

