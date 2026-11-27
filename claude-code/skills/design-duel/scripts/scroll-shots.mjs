// Scroll-by-viewport screenshots through Chrome DevTools Protocol.
// Usage: node scroll-shots.mjs <url> <outPrefix> <width> <height> [mobile]
import { spawn } from 'node:child_process';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';

const [, , url, prefix, w, h, mobile] = process.argv;
const width = Number(w), height = Number(h);
const port = 9300 + Math.floor(Math.random() * 500);
const prof = fs.mkdtempSync(path.join(os.tmpdir(), 'cdp-'));
const chromeBin = process.env.CHROME_BIN || "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome";
const chrome = spawn(chromeBin, [
    '--headless=new', '--disable-gpu', '--hide-scrollbars', `--remote-debugging-port=${port}`, `--user-data-dir=${prof}`, 'about:blank',
], { stdio: 'ignore' });
const sleep = (ms) => new Promise((r) => setTimeout(r, ms));
let target;
for (let i = 0; i < 50 && !target; i++) {
    await sleep(200);
    try { target = (await (await fetch(`http://127.0.0.1:${port}/json`)).json()).find((t) => t.type === 'page'); } catch {}
}
const ws = new WebSocket(target.webSocketDebuggerUrl);
await new Promise((r) => ws.addEventListener('open', r));
let id = 0; const pending = new Map();
ws.addEventListener('message', (e) => { const m = JSON.parse(e.data); if (m.id && pending.has(m.id)) { pending.get(m.id)(m.result); pending.delete(m.id); } });
const send = (method, params = {}) => new Promise((r) => { const i = ++id; pending.set(i, r); ws.send(JSON.stringify({ id: i, method, params })); });
await send('Emulation.setDeviceMetricsOverride', { width, height, deviceScaleFactor: 1, mobile: Boolean(mobile) });
await send('Page.enable');
await send('Page.navigate', { url });
await sleep(6000);
const total = (await send('Runtime.evaluate', { expression: 'document.documentElement.scrollHeight', returnByValue: true })).result.value;
let n = 0;
for (let y = 0; y < total; y += height) {
    await send('Runtime.evaluate', { expression: `window.scrollTo(0, ${y})` });
    await sleep(1200);
    const { data } = await send('Page.captureScreenshot', { format: 'jpeg', quality: 70 });
    fs.writeFileSync(`${prefix}-${String(n++).padStart(2, '0')}.jpg`, Buffer.from(data, 'base64'));
}
console.log('shots', n, 'height', total);
ws.close(); chrome.kill();
