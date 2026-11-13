#!/usr/bin/env node
// Trigger CSS Loader's "Refresh" on the Deck remotely — the same call its own UI makes
// (reloadBackend -> callPluginMethod("reset")). Requires Node 22+ and Decky's
// "Allow Remote CEF Debugging" enabled. Usage: node tools/cssloader-refresh.mjs <deck-host>
const host = process.argv[2];
if (!host) { console.error("usage: cssloader-refresh.mjs <deck-host-or-ip>"); process.exit(64); }
const targets = await (await fetch(`http://${host}:8081/json`, { signal: AbortSignal.timeout(4000) })).json();
const t = targets.find(x => x.title === "SharedJSContext");
if (!t) { console.error("SharedJSContext not found (is Gaming Mode running?)"); process.exit(1); }
const expr = `(async()=>{const r=await window.DeckyPluginLoader.createLegacyPluginAPI("CSS Loader").callPluginMethod("reset",{});return JSON.stringify(r.success)})()`;
const ws = new WebSocket(t.webSocketDebuggerUrl);
ws.onopen = () => ws.send(JSON.stringify({ id: 1, method: "Runtime.evaluate", params: { expression: expr, returnByValue: true, awaitPromise: true } }));
ws.onmessage = m => { const r = JSON.parse(m.data); if (r.id !== 1) return;
  const ok = r.result?.result?.value === "true"; console.log(ok ? "CSS Loader refreshed." : "Refresh failed: " + JSON.stringify(r.result)); process.exit(ok ? 0 : 1); };
setTimeout(() => { console.error("timeout"); process.exit(2); }, 15000);
