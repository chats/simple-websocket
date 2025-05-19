require('dotenv').config();
const express = require('express');
const { WebSocketServer } = require('ws');
const http = require('http');
const { createClient } = require('redis');

const PORT = process.env.PORT || 3000;
const API_KEY = process.env.API_KEY;
const USE_REDIS = process.env.USE_REDIS === 'true';
const REDIS_URL = process.env.REDIS_URL;
const WEBSOCKET_PATH = process.env.WEBSOCKET_PATH || '/ws';
const WEBHOOK_PATH = process.env.WEBHOOK_PATH || '/webhook';

const app = express();
app.use(express.json());

const server = http.createServer(app);
const wss = new WebSocketServer({ server, path: WEBSOCKET_PATH || '/ws' });

const clients = new Set();
wss.on('connection', (ws, req) => {
  const url = new URL(req.url, `http://${req.headers.host}`);
  const apiKey = url.searchParams.get('api_key');

  if (apiKey !== API_KEY) {
    ws.close(1008, 'Unauthorized');
    return;
  }

  clients.add(ws);
  ws.on('close', () => clients.delete(ws));
});

// Broadcast function
const broadcast = (data) => {
  for (const ws of clients) {
    if (ws.readyState === ws.OPEN) {
      ws.send(JSON.stringify(data));
    }
  }
};

// Redis pub/sub
let redis;
if (USE_REDIS) {
  redis = createClient({ url: REDIS_URL });
  redis.connect().then(() => {
    console.log('✅ Redis connected');
    redis.subscribe('webhook-events', (message) => {
      const data = JSON.parse(message);
      broadcast(data);
    });
  }).catch(err => console.error('Redis error:', err));
}

// Dynamic webhook topic route
app.post(`${WEBHOOK_PATH || '/webhook'}/topic/:topic`, async (req, res) => {
  const topic = req.params.topic;
  const payload = req.body;
  const walletId = req.headers['x-wallet-id'];

  //console.log(`📥 Webhook received for topic: ${topic}`);
  //console.log(`🪪 x-wallet-id: ${walletId}`);

  const message = {
    topic,
    payload
  };

  if (USE_REDIS && redis) {
    await redis.publish('webhook-events', JSON.stringify(message));
  } else {
    broadcast(message);
  }

  res.sendStatus(200);
});

// Health check
app.get('/healthz', (_, res) => res.send('OK'));

// Start server
server.listen(PORT, () => {
  console.log(`🚀 Server running on http://localhost:${PORT}`);
  console.log(`📡 WebSocket endpoint: ws://localhost:${PORT}${WEBSOCKET_PATH}?api_key=YOUR_KEY`);
  console.log(`📬 Webhook endpoint: POST http://localhost:${PORT}${WEBHOOK_PATH}`);
});
