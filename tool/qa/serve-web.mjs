#!/usr/bin/env node
/**
 * Tiny static server with SPA fallback to index.html (GoRouter path URLs).
 * Usage: node serve-web.mjs [dir] [port]
 */
import http from 'node:http';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const root = path.resolve(
  process.argv[2] || path.join(__dirname, '../../build/web'),
);
const port = Number(process.argv[3] || process.env.PORT || 8080);

const TYPES = {
  '.html': 'text/html; charset=utf-8',
  '.js': 'text/javascript; charset=utf-8',
  '.mjs': 'text/javascript; charset=utf-8',
  '.css': 'text/css; charset=utf-8',
  '.json': 'application/json',
  '.png': 'image/png',
  '.jpg': 'image/jpeg',
  '.jpeg': 'image/jpeg',
  '.svg': 'image/svg+xml',
  '.webp': 'image/webp',
  '.wasm': 'application/wasm',
  '.ttf': 'font/ttf',
  '.otf': 'font/otf',
  '.woff': 'font/woff',
  '.woff2': 'font/woff2',
  '.map': 'application/json',
};

function send(res, status, body, type) {
  res.writeHead(status, {
    'Content-Type': type || 'text/plain; charset=utf-8',
    'Cache-Control': 'no-cache',
  });
  res.end(body);
}

function safeJoin(base, reqPath) {
  const decoded = decodeURIComponent(reqPath.split('?')[0]);
  const joined = path.normalize(path.join(base, decoded));
  if (!joined.startsWith(base)) return null;
  return joined;
}

const server = http.createServer((req, res) => {
  const urlPath = req.url || '/';
  let filePath = safeJoin(root, urlPath === '/' ? '/index.html' : urlPath);
  if (!filePath) {
    send(res, 403, 'Forbidden');
    return;
  }

  fs.stat(filePath, (err, stat) => {
    if (!err && stat.isDirectory()) {
      filePath = path.join(filePath, 'index.html');
    }
    fs.readFile(filePath, (readErr, data) => {
      if (!readErr) {
        send(res, 200, data, TYPES[path.extname(filePath)] || 'application/octet-stream');
        return;
      }
      // SPA fallback for client routes (/dashboard, /customers, …)
      const indexPath = path.join(root, 'index.html');
      fs.readFile(indexPath, (indexErr, indexData) => {
        if (indexErr) {
          send(res, 404, 'Not found');
          return;
        }
        send(res, 200, indexData, TYPES['.html']);
      });
    });
  });
});

server.listen(port, '127.0.0.1', () => {
  console.log(`[qa-serve] ${root} → http://127.0.0.1:${port}`);
});
