# DeckThemes submission checklist

Audit of Slate against the DeckThemes CSS theme requirements (2026-11-14).

| Requirement | Status | Notes |
|---|---|---|
| Original author / permission | ✅ | Written for this repo; MIT. |
| Copyright of all contents with the author or attributed | ✅ | CSS only — no images, fonts or third-party assets. |
| Target marked appropriately, only styles that target | ✅ | `"target": "System-Wide"` (was `Home` until 0.5.0 — the theme now styles every Gaming Mode screen). |
| Works on latest **beta and stable** SteamOS, Decky Loader, CSS Loader | ⚠️ | Verified on stable (SteamOS 3.9.5, CSS Loader 2.1.3). **Beta not tested yet** — must be checked before submitting. |
| `*` / `!important` only if absolutely necessary | ✅ | No universal selector. `!important` only against inline styles or Steam's own `!important`: playcount-decky badge (inline `style` on `.playerBadge > button`), protondb-decky trend border (inline), Store Deck-Compatibility dialog (Steam `!important`). Each is commented in place. |
| Under 10 MB, least disk space | ✅ | ~230 KB for the whole repo; the theme itself is `theme.json` + `css/` (~136 KB). |
| Preview image without text (unless describing options) | ⏳ | No preview image yet — to make for the v1.0.0 submission. |
| Safe for work | ✅ | |
| CSS variables prefixed with a unique identifier | ✅ | All variables Slate defines are `--slate-*` (plus keyframes `slate-*`). Other custom properties in the CSS are Steam's own (`--color-*`, `--gp*`, `--key-*`, `--left-track-color`, …) being overridden, not new ones. |
| Doesn't bundle other themes; uses dependencies | ✅ | No bundled themes, no dependencies needed. |
| Keyboard theming applies to the default keyboard | ✅ | Only `.virtualkeyboard_Keyboard.DefaultTheme`; Points Shop keyboard themes untouched. |
| System-wide theme targeting the keyboard → keyboard theming toggleable | ✅ | **Keyboard** option (CSS Loader › Slate › Keyboard: Slate / Steam). `css/keyboard.css` is only injected by that patch. Verified on hardware (toggling removes/restores the rules). |

Open before submitting: beta-channel test, preview image.
