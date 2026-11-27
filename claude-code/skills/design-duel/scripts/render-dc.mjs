// Renders a .dc.html artboard to static HTML for screenshotting.
// Usage: node render-dc.mjs <in.dc.html> <out.html> <blobmap.json>
import fs from 'node:fs';

const [, , inPath, outPath, mapPath] = process.argv;
const src = fs.readFileSync(inPath, 'utf8');
const blobMap = JSON.parse(fs.readFileSync(mapPath, 'utf8'));

const helmet = (src.match(/<helmet>([\s\S]*?)<\/helmet>/) || [, ''])[1];
let body = (src.match(/<x-dc>([\s\S]*?)<\/x-dc>/) || [, ''])[1].replace(/<helmet>[\s\S]*?<\/helmet>/, '');
const script = (src.match(/<script type="text\/x-dc"[^>]*>([\s\S]*?)<\/script>/) || [, ''])[1];

class DCLogic { constructor() { this.props = {}; this.state = {}; } setState() {} }
const Component = new Function('DCLogic', `${script}; return Component;`)(DCLogic);
const vals = new Component().renderVals();

const lookup = (scope, path) => path.split('.').reduce((o, k) => (o == null ? undefined : o[k]), scope);
const literal = (p) => (p === 'true' ? true : p === 'false' ? false : undefined);
const resolve = (scope, raw) => { const p = raw.trim(); const l = literal(p); return l !== undefined ? l : lookup(scope, p); };
const fill = (html, scope) => html.replace(/\{\{\s*([^}]+?)\s*\}\}/g, (_, p) => { const v = resolve(scope, p); return v == null ? '' : String(v); });
const ifs = (html, scope) => html.replace(/<sc-if value="\{\{\s*([^}]+?)\s*\}\}"[^>]*>([\s\S]*?)<\/sc-if>/g, (_, p, inner) => (resolve(scope, p) ? inner : ''));

body = body.replace(/<sc-for list="\{\{\s*([^}]+?)\s*\}\}" as="(\w+)"[^>]*>([\s\S]*?)<\/sc-for>/g, (_, listPath, as, inner) => {
    const list = resolve(vals, listPath) || [];
    return list.map((item, i) => { const scope = { ...vals, [as]: item, $index: i }; return fill(ifs(inner, scope), scope); }).join('');
});
body = fill(ifs(body, vals), vals);
body = body.replace(/<video\b([^>]*?)poster="([^"]+)"([^>]*)><\/video>/g, (_, a, poster, b) => {
    const style = ((a + b).match(/style="([^"]*)"/) || [, ''])[1];
    return `<img src="${poster}" alt="" style="${style}">`;
});
let out = `<!doctype html><html><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">${helmet}</head><body>${body}</body></html>`;
out = out.replace(/\/_blob\/([0-9a-f]{32})/g, (m, id) => (blobMap[id] ? `assets/${blobMap[id]}` : m));
fs.writeFileSync(outPath, out);
console.log('rendered', outPath, out.length);
