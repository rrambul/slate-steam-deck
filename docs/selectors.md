# Verified selectors

Captured live via CEF DevTools (<deck-ip>:8081, target "Steam Big Picture Mode").
SteamOS 3.9.5 · CSS Loader 2.1.3 · 2026-11-13.

CSS Loader rewrites stable names (e.g. `.appportrait_LibraryItemBox`) to Steam's
hashed classes using `~/homebrew/themes/css_translations.json`. Write selectors with the
stable names, never the hashes.

## Home → Recent Games: focused game card

Focused element chain (innermost first):

| Hashed class (this build)   | Stable name                                          |
|-----------------------------|------------------------------------------------------|
| `WYgDg9NyCcMIVuMyZ_NBC`     | `appportrait_LibraryItemBox`                         |
| `_1Pf6J2JFkZ-oRpe0_7cabJ`   | `appportrait_Portrait`                               |
| `biTV-8rS2M65imVHU15Nv`     | `appportrait_InRecentGames`                          |
| `_3vi6SfAX2Pp-9TVSjvm5Et`   | `appportrait_BasicMode`                              |
| (parent) `_1pwP4eeP1zQD7PEgmsep0W` | `appportrait_Draggable`                       |
| (ancestor) `_1HIFNGSxh4-jOhPiDynR4C` | `basicgamecarousel_BasicGameCarouselItemMediaContainer` |
| (ancestor) `_3YYQ98HSj-wh5uljwl12bW` | `basicgamecarousel_BasicGameCarouselItem`     |

The card itself carries `gpfocus` when selected; ancestors carry `gpfocuswithin`.

Candidate M1 selector (focused Home card):

```css
.appportrait_InRecentGames.gpfocus
```

Baseline computed styles on the focused card: `border-radius: 0px`,
`box-shadow: rgba(0,0,0,0.25) 0 4px 10px 0`, no outline.

## M1 — rounded Recent Games cards (verified 2026-11-13)

```css
.appportrait_InRecentGames,
.appportrait_InRecentGames .libraryassetimage_Container,
.appportrait_InRecentGames .libraryassetimage_Image { border-radius: var(--slate-radius-card); }
```

Rationale:
- `appportrait_InRecentGames` scopes the change to the Home carousel only; library
  grid portraits are untouched.
- Radius goes on card, image container and `<img>` instead of `overflow: hidden` on the
  focusable card, so Steam's focus outline, lift (translateZ) and shadow are not clipped.
- Steam's focus treatment (white 2px outline at ~60%, translateZ, deeper shadow,
  unfocused cards at brightness 0.9) is kept as is: it is already understated and is
  the controller's main focus cue. A grey #575B63 outline was rejected as too low-contrast.

Verified via CDP: focused + unfocused cards and their `<img>` compute `border-radius: 8px`;
focus outline follows the radius. Screenshots: docs/screenshots/m1-{before,after}.png (local only).

## M2 — tokens + neutral canvas (verified 2026-11-13)

| Stable name | Hashed (this build) | Steam default | Slate |
|---|---|---|---|
| `gamepadui_BasicHome.gamepadui_OpaqueBackground` | `_3LYP1SIxyoky-yW9Ug_1fq.b084mAvY8rgVMr3H04g9g` | radial-gradient rgb(6,10,14) → rgb(14,20,27) | `--slate-bg-deep` → `--slate-bg`, same geometry |
| `appportrait_InRecentGames .libraryassetimage_Container` | `… ._1R9r2OBCxAmtuUVrgBEUBw` | rgb(14,20,27) placeholder | `--slate-surface` |

Notes:
- `gamepadui_BasicHome` has two other variants (`background: #000` and transparent);
  the compound selector only touches the opaque one.
- `gamepadui_BasicHome` is shared across Gaming Mode pages, so the canvas change is
  global by design (Library etc.).
- Untouched: hero art (`gamepadhomerecentgames_RecentGamesBackgroundContainer` /
  `…BackgroundImages`, masked radial gradient, art at brightness 0.5),
  `footer_BasicFooter` (rgba(0,0,0,.5)), `gamepadtabbedpage_TabsRowScroll`.

Verified via CDP: canvas computes rgb(11,12,14) → rgb(17,18,20); placeholder rgb(32,34,38).
Screenshots: docs/screenshots/m2-{before,after}.png (local only).
