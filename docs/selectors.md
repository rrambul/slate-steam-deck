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

## M3 — rounded What's New news cards + scoped focus ring (verified 2026-11-13)

| Stable name | Hashed (this build) | Role |
|---|---|---|
| `gamepadhomewhatsnew_LibraryHomeWhatsNew` | `rvYRfhjWoi57GShuRcAwP` | What's New section root (stable scope) |
| `focusring_FocusRing` | `_1wPplsegQqCoe06wXPhzKT` | global focus-ring overlay, follows the focused element |
| `gamepadtabbedpage_Tab` / `…_Selected` | `_3eEbSktrstBdLk0dVpnKVI` / `_3Gp1bACHx__POxmy6Gd3kG` | Home tabs (not styled) |

News card wrappers (`B1DxY2t9t_oR_fXgqs7Dj`, image box `_3Yd9bnm5cESPzqV_j5-WJt`) have
**no** entry in css_translations.json, so they're matched structurally:
`.Focusable:has(> div > img:not(.libraryassetimage_Image):not(.avatar))` inside the section root.
Matches only the 300×265 news cards (not game capsules, icons or friend avatars).

Lessons:
- Rounding only the `<img>` left square text panels and a square focus ring → round the card
  with `overflow: hidden` instead. The focus ring is a separate overlay, so it isn't clipped.
- The focus ring is global; rounding it unscoped would change every focus ring in Gaming Mode.
  Scoped with `:root:has(<focused news card>) .focusring_FocusRing`.
- `:has()` cannot be nested — a nested `:has` invalidates the whole rule silently.
- Tabs left alone: Steam's selected tab (rgba(255,255,255,.15)) already reads neutral on
  charcoal; `--slate-surface` would lower its contrast.

Verified via CDP with focus on a news card: 8 cards at 8px + overflow hidden, ring 8px,
Recent Games cards still 8px. Screenshots: docs/screenshots/m3-{before,after}.png (local only).

## M3b — "Recently updated on this device" cards (verified 2026-11-13)

All stable names — no structural selector needed:

| Stable name | Hashed (this build) |
|---|---|
| `recentlycompleted_RecentlyCompleted` (section) | `_3fDIRGKWUAQUCORORZWL_f` |
| `recentlycompleted_RecentlyCompletedItem` (card, focusable) | `_3OC7iN2ubQiHWLB7r6Bugz` |
| `recentlycompleted_TopSection` / `…_BottomSection` | `_2wVB-Jwr3riFpZ5WPITH4b` / `_3LyF6X2UzrKOnCPSpoVFeT` |
| `recentlycompleted_GameIcon` / `…_GameIconAndName` | `DqP6rAoIUfL1XKDK0rQy7` / `_2RTo4iH5C026PtVTtWrBK3` |

Card: `border-radius` + `overflow: hidden` (clips the rgba(255,255,255,.05) BottomSection).
The item itself receives `gpfocus`, so it's added to the focus-ring `:root:has(...)` list.

Verified via CDP: 8 items at 8px/hidden; with one focused, `focusring_FocusRing` = 8px.
Not yet styled on Home: "Trending among friends" row.

## M3c — Home store carousels / "Trending among friends" (verified 2026-11-13)

| Stable name | Hashed (this build) |
|---|---|
| `homestorecarousel_StoreCarouselCtn` (row container) | `_3zVCVKrpcKJT5fd_dbyuwQ` |
| `homestorecarousel_Header` | `xpRXvu3-lbtUHYWgwJCiJ` |
| `gamecapsule_GameCapsule` (card, focusable) | `fXdhjvKWFQqnjxUzju3jk` |
| `gamecapsule_BottomBar` (friends / price bar) | `_3-GyQfKnKaWozIRLOw4BjY` |

`gamecapsule_GameCapsule` is a shared Steam component → scoped to
`.homestorecarousel_StoreCarouselCtn` so other pages are untouched. Card gets
`border-radius` + `overflow: hidden`; focused capsule added to the focus-ring list.

Verified via CDP with a capsule focused: 11 capsules at 8px/hidden, 0 capsules outside
the carousel, ring 8px; Recent Games and Recently updated still 8px.
Screenshot: docs/screenshots/m3c-after.png (local only).

### Home rounding — complete
All card rows on Home now share `--slate-radius-card`: Recent Games, What's New news,
Recently updated, Trending among friends.

### M3d — remaining navy tints on Home (commit ba3f345 says "M4" by mistake) (verified 2026-11-13)
- `gamecapsule_GameCapsule` background `rgb(35,38,46)` → `--slate-surface` ✅
- `libraryassetimage_Container` placeholder `rgb(14,20,27)` in What's New → `--slate-surface` ✅
  (Recent Games was already covered by M2.)
- `gamecapsule_BottomBar` Steam blue `rgb(60,93,132)` → `--slate-muted` ✅ (chosen from A/B:
  docs/screenshots/bar-A-keep-blue.png vs bar-B-neutral.png). Similar luminance, so white
  text stays readable. "NEW" (`rgb(58,155,237)`) and "IN LIBRARY" (`rgb(79,149,189)`) badges
  intentionally keep their blue as Home's single status accent.

Verified via CDP on Home: capsules and 20 What's New placeholders compute rgb(32,34,38);
no navy left inside Home; 11 BottomBars compute rgb(87,91,99), 0 outside Home.
Navy background/placeholders remain in Library (out of Home scope).

## L1 — Library canvas + placeholders (verified 2026-11-13)

| Stable name | Hashed (this build) | Steam default | Slate |
|---|---|---|---|
| `gamepadlibrary_GamepadLibrary` | `ZBBhezbBR4VJYysmVhF3_` | own copy of navy radial gradient, painted over the canvas | `var(--slate-canvas)` |
| `gamepadlibrary_GamepadLibrary .libraryassetimage_Container` | `… ._1R9r2OBCxAmtuUVrgBEUBw` | `rgb(14,20,27)` | `--slate-surface` |
| `appportrait_InCollection` (Library card) | `_3ANruIVwRSgaU7L1eWRnf8` | square | 8px (L2) |
| `cssgrid_CSSGrid` (Library grid) | `_3vHkmRShhzwd67_MtEq8-n` | — | — |

- New token `--slate-canvas` holds the gradient once; Home canvas and Library share it.
- Library gets the canvas explicitly (not `transparent`): in the in-game overlay the
  `gamepadui_BasicHome` underneath uses the transparent variant.

Verified via CDP in Library (Installed + All Games tabs): Library and canvas compute the same
gradient rgb(11,12,14) → rgb(17,18,20); 50 placeholders rgb(32,34,38); 0 navy elements on screen.
Screenshots: docs/screenshots/lib-{before,after}.png (local only).

## L2 — rounded Library cards (verified 2026-11-13)

Same approach as M1: radius on `appportrait_InCollection`, its `libraryassetimage_Container`
and `libraryassetimage_Image`. Focus is Steam's own outline on the card
(`rgba(255,255,255,.6) 2px`), which follows the radius.

Tried and dropped: `overflow: hidden` on the card. Steam sets
`.BasicUI .appportrait_LibraryItemBox { overflow: visible }` (0,2,0) in Gaming Mode on purpose
(its non-BasicUI default is `hidden`), which beats a single-class rule. Not worth escalating:
the DEMO ribbon crosses the card away from the corner, so nothing pokes out.
Debug tip: `CSS.getMatchedStylesForNode` over CDP shows every matching rule, including ones in
stylesheets that `document.styleSheets` can't read.

Verified via CDP + screenshot (All Games, DEMO card "Kings" focused): 25 cards 8px,
images 8px, focus outline follows the radius, ribbon inside the corner.
Screenshot: docs/screenshots/l2-after.png (local only).
