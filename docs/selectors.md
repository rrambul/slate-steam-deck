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

### M3d — remaining navy tints on Home (commit bcf6114 says "M4" by mistake) (verified 2026-11-13)
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

## G1 — game details page backgrounds (verified 2026-11-13)

Static styling (no per-game inline color), so it can be overridden with plain rules that
mirror Steam's specificity — no `!important`.

| Stable selector (mirrors Steam's) | Hashed (this build) | Steam default | Slate |
|---|---|---|---|
| `.appdetails_ScrollContainer` | `_2l416KfEtI4CL0mCUEmOBw` | `#24282f` | `--slate-bg` |
| `.appdetails_ScrollContainer.appdetails_Glassy` | `… ._3FmxxjyWNHU1PrBGnBe6tm` | radial rgb(44,50,61) → rgb(21,22,22) | radial `--slate-surface` → `--slate-bg` (same geometry) |
| `.BasicUI .basicappdetailssectionstyler_AppDetailsRoot` | `_3fp5y6tdU77MdrCQZt_aS9` | `rgba(14,20,27,.25)` | `--slate-bg` @ 25% (color-mix) |
| `.BasicUI .appdetailssection_AppDetailsSectionContainer.appdetailssection_RightColumnSection` | `_31ptFGGMZrSQc5BCX1e5lm._3KfxIwlXEvum7FCD_AM2_t` | `rgba(103,112,123,.2)` | `--slate-muted` @ 20% |

Also on this page: `smartscrollcontainer_Body` (`_3lDczhulqraStjCitLYJ1K`),
`sharedappdetailsheader_TopGradient` (`_1IWSiRVmH1DlNlWSaBeUuZ`, black fade over hero — kept).
Untouched on purpose: hero art, Install/Play button (`rgb(26,159,255)`), plugin badges
(ProtonDB, playcount, etc. — owned by other Decky plugins).

Verified via CDP on an app page: page rgb(17,18,20) + radial rgb(32,34,38) → rgb(17,18,20);
panel and row compute the color-mix values; Install button unchanged.
Screenshots: docs/screenshots/app-{before,after}.png (local only).

## G2 — primary action button (verified 2026-11-13, incl. green Play)

In Gaming Mode the action button is **transparent until focused**; Steam then paints it.

| Stable name | Hashed (this build) |
|---|---|
| `basicappdetailssectionstyler_AppActionButton` (wrapper) | `QsZdWtHTlIK9KIKbscNTt` |
| `appactionbutton_PlayButton` (main half) | `_3ydigb6zZAjJ0JCDgHwSYA` |
| `appactionbutton_ButtonChild` (each half) | `_2AzIX5kl9k6JnxLfR5H4kX` |
| `appactionbutton_ButtonText` | `_33cnXIqTRgRr49_FNXIHj6` |
| `appactionbutton_Green` (Play state) | `_3cI5TXsFX3bvpR-7EBOtxq` |
| `appactionbutton_Disabled` / `…_ShutdownAppButton` | `_1Pb6PMh_3L5p5NzuUz0Pp9` / `_1WVYDQv_srgKP95rVG1cX-` |

Steam (from library.css): `.BasicUI .ButtonChild.Focusable:focus { background:#1a9fff; color:#fff }` (0,4,0);
Play: `.BasicUI .Green .ButtonChild.Focusable:focus { background:#59bf40 }` (0,5,0).
Steam already uses white/#0e141b for the focused dropdown half — Slate extends that.

Slate (revised same day, user choice "keep blue, but our blue"): focused → `--slate-blue` `#2D74C4`
with white text (4.8:1; Steam's #1a9fff was 2.82:1). Play focused/hover → `--slate-green` `#2B8659`
(white 4.5:1; Steam's #59bf40 was 2.35:1). Blue and green have matched luminance, so they read as a pair.
First iteration (light `--slate-text` pill, commit 1760586) was replaced by this.
The dropdown half keeps Steam's own focused style (white / #0e141b) — its rule (0,5,0) outranks
the generic one (0,4,0), which is intended.

Verified via CDP + screenshot: main half focused = Slate blue + white label; dropdown focused =
rgb(255,255,255) / rgb(14,20,27). Screenshot: docs/screenshots/g2-blue-after.png (local only).
Green Play verified on an installed game: focused = rgb(43,134,89).
Tip: Steam's own rules can be read with `fetch(sheet.href)` from the page when CSSOM access fails.

## P1 — third-party plugin badges on the game page (verified 2026-11-13)

| Plugin | Selector | Styling source |
|---|---|---|
| protondb-decky | `.protondb-decky-indicator.protondb-decky-indicator-regular` + tier class `…-indicator-{platinum,gold,silver,bronze,borked,pending}` | plugin CSS (single class) → two-class selector wins |
| protondb-decky | `.protondb-decky-info-button` (`…-info-working` / `…-info-not-working`), `.protondb-decky-submit-button` | plugin CSS |
| playcount-decky | `.playerBadge > button` | **inline styles** → `!important` (only place in Slate) |

Plugin tier colors: platinum rgb(180,199,220), gold rgb(207,181,59), silver rgb(166,166,166),
bronze rgb(205,127,50), borked rgb(200,30,30), pending rgb(68,68,68); info working rgb(74,194,100).
Slate: `--slate-glass` + 12px blur, 8px radius, tier color as `--slate-accent` (text/icon + 35% inset ring);
borked → #f87171, pending → #A3A6AD, silver → rgb(190,190,190) for legibility on dark glass.
Plugin class names are owned by the plugins and may change with plugin updates.

Lesson: never pass preview CSS through shell quoting — `inject.mjs` loads it from a file.

Verified via CDP: gold badge glass + rgb(207,181,59), info rgb(74,222,128), submit rgb(201,203,208),
pill glass/8px/white. Screenshot: docs/screenshots/g2p1-after.png (local only).

## G3 — game page shapes + last cool tints (verified 2026-11-13)

| Stable name | Hashed (this build) | Steam | Slate |
|---|---|---|---|
| `basicappdetailssectionstyler_AppActionButton` (wrapper) | `QsZdWtHTlIK9KIKbscNTt` | 2px (`.BasicUI`) | 8px |
| `appactionbutton_PlayButton` / `…_ShowingStreaming …` | `_3ydigb6zZAjJ0JCDgHwSYA` / `_1hhB2Wf7iExA15zh_lDQ_y` | 2px / 2px 0 0 2px | 8px / 8px 0 0 8px |
| `appactionbutton_StreamingSelector` (dropdown half) | `_2q-gZ3XJzlvSGHSF-GvSmi` | 0 2px 2px 0 | 0 8px 8px 0 |
| `appdetailsplaysection_MenuButton` (gear/controller) | `_3qDWQGB0rtwM3qpXTb11Q-` | 2px, rgba(172,178,201,.14) | 8px, `--slate-raised` |
| `appdetailsplaysection_ControllerConfigButton` | `_1oYt_BfxCHnA-_6sfUHiNn` | (variant of MenuButton) | — |
| `appactivityday_Event .appactivityday_EventHeadline` | `UVeN0kaD3zv1feMj_mMw5 .QCKBqF2k_sRLcXJ5qQIEl` | 0, rgba(172,178,201,.14) | 8px top, `--slate-raised` |
| `appactivityday_Event .appactivityday_EventBody` | `… .NEMXhMlqXOCJwfgWlHXhT` | 0, rgba(172,178,201,.14) | 8px bottom, `--slate-raised` |
| `appdetailssection_AppDetailsSectionContainer.…RightColumnSection` | (see G1) | 0 | 8px |

- New token `--slate-raised: rgba(244,244,245,.10)` — neutral overlay at the same brightness as
  Steam's blue-grey rgba(172,178,201,.14).
- No `overflow: hidden` on the action-button wrapper (streaming callout may render outside).
- Headline is always directly followed by EventBody (9/9 observed) → reads as one card.

Verified via CDP + screenshot on an installed game (Play focused = Slate green; ProtonDB Platinum
accent rendered). Screenshot: docs/screenshots/g3-after.png (local only).

## Split check (2026-11-13)
After splitting `shared.css` into `css/*.css`, the live Slate rule set on the Deck (39 rules, dumped via
CDP and sorted) was byte-identical to the pre-split baseline.

## G4 — game page tabs: Your Stuff / Community / Game Info (verified 2026-11-13)

Steam's navy `#23262e` → `--slate-surface`; cool `#3d4450` → new token `--slate-control` `#434347`
(same luminance); 0–2px → 8px. Steam rules read from library.css via `fetch(sheet.href)`.

| Stable selector (mirrors Steam's) | Hashed | Steam (Gaming Mode) |
|---|---|---|
| `.BasicUI .appdetailssection_Highlight` (achievements panel) | `_38t1mljBjmJfqjpVzMT1CG` | `#23262e`, 0 |
| `.appdetailsachievementssection_AchievementCarouselItem.…_Detailed` | `mbFSnoK85dUXHz9VT-YNI._3KGi6ig3JCLHZP-dOsO-Wx` | `#3d4450` |
| `.BasicUI .appdetailscommunityfeed_CommunityItem` | `_3QS6OBHpvI5bXsSQA2zQuW` | `#23262e`, 0 (desktop BPM: 6px) |
| `.BasicUI .appdetailscommunityfeed_ArtItem .…_BottomSection` | `_1aP1bu_l_kDbKMN7XDNmzg ._3uabislt81gdMksbxzc-iN` | rgba(14,20,27,.72) |
| `.appdetailsgameinfopanel_DeckVerifiedInfo` (+ `.…_Focused`) | `IIJeieZ-ZPRfIULY7uSDG` (+ `_1wl1mQLRXzpgY5WzEEtDm-`) | `#23262e` / `#3d4450`, 2px |
| `.appdetailsgameinfopanel_DeckVerifiedInfo .…_Details` | `… ._3sfpA6uM8IJuAnrtDiJLZI` | `#3d4450`, 2px |
| `.BasicUI .appdetailsprimarylinkssection_Anchor` (+ `.…_Link`) | `DY4_wSF8h9T5o46hO5I9V` (+ `_1b6LYWVijW-9E4YV0keDWZ`) | `#3d4450`, 2px; focus white |
| `.appdetails_ScrollContainer .libraryassetimage_Container` | `… ._1R9r2OBCxAmtuUVrgBEUBw` | `rgb(14,20,27)` |

Focus ring rounded while a community card (or a child) has focus — same `:root:has()` pattern as Home.

Verified: Game Info + Community via after-screenshots and inventory (no cool tints left);
Your Stuff panels via CDP (highlight rgb(32,34,38)/8px, tiles rgb(67,67,71)/8px).
Open: Media thumbnails (`appdetailsscreenshotssection_Thumbnail` / `screenshots_ClickableScreenshot`)
and DLC capsule still square; achievements progress fill still Steam blue rgb(26,159,255)
(`_2YzOLNBx6TonKU0Zmp20l4`, unnamed yet).

## C1 — "our colors" for generic badges/accents (2026-11-13)

Rule (user decision): generic accents → Slate colors; colors that **are** the information keep
their hue (ProtonDB tiers). A first pass mapped tiers to Slate status colors; reverted the same day.

| Element | Selector | Steam/plugin | Slate | Verified |
|---|---|---|---|---|
| Achievements progress fill | `.appdetailsachievementssection_HighlightDiv { --color-blue-8: … }` | Steam token `--color-blue-8` #1A9FFF | `--slate-blue` | ✅ fill rgb(45,116,196); `:root` token untouched |
| ProtonDB info (working / not) | `.protondb-decky-info-button.protondb-decky-info-{working,not-working}` | #4ade80 / red | `--slate-green-light` / `--slate-red` | ✅ rgb(91,191,138) |
| playcount online dot | `.playerBadge > button > div:first-child svg` (inline → `!important`) | rgb(76,175,80) | `--slate-green-light` | ✅ |
| ProtonDB tiers | unchanged tier colors | — | — | ✅ platinum rgb(180,199,220) |
| Home IN LIBRARY | `.homestorecarousel_StoreCarouselCtn .gamecapsule_InLibrary` | #4f95bd / black text | `--slate-blue` / white | ✅ rgb(45,116,196)/white |
| Home NEW | `… [class*="SalePriceWidgetContainer"] > div:first-child:not(:only-child)` (no stable class) | #3a9bed | `--slate-blue` / white | ✅ rgb(45,116,196); only "New" matched (lone "To be announced" excluded) |

Steam has its own token scale `--color-blue-1…12` on `:root`. Scoped re-pointing of a Steam token
inside a stable container is the cleanest way to recolor new-style components without hashed classes.
New tokens: `--slate-green-light #5BBF8A`, `--slate-red #E07A7A`, `--slate-muted-light #A3A6AD`.

### C2 — Deck "Verified" check → Slate green (verified 2026-11-13)
`.kEODDe6M5cuHWuPlcQexX { color: var(--slate-green-light) }` — hashed class on purpose: no stable
name, no Steam token. If Steam renames it, the rule stops matching and the icon falls back to
Steam's #59bf40 (**fails safe**); a structural selector could recolor the yellow "Playable" icon.
Verified via CDP: Game Info tab-header icons and the compatibility box icon = rgb(91,191,138).
Battery icon (system status bar) intentionally untouched.

## ⚠ CSS Loader rewrites short names — everywhere

CSS Loader's translation replaces any **translation name** found in theme CSS with the current
hash — including short names (`StoreSalePriceWidgetContainer`) and even text **inside quoted
attribute selectors** (`[class~="…"]`). If that short name belongs to a *different* component,
the selector silently targets the wrong element.

- Lost two iterations on Home's NEW badge to this (`.StoreSalePriceWidgetContainer` and
  `[class~="StoreSalePriceWidgetContainer"]` both became `_2s-O5T…` from `salepreviewwidgets_`).
- Fix: `[class*="SalePriceWidgetContainer"]` — a substring that is *not* a translation name.
- **Always verify against the injected CSS** (read `head style` text / computed style after Refresh),
  not with a raw `querySelector` test, which bypasses CSS Loader's translation.
- Check: every bare class in `css/*.css` was compared with the translation table; this was the
  only collision. Hashed classes that are translation *values* (e.g. `kEODDe…`) map to themselves
  and are tracked across Steam updates.

### M3f — NEW / IN LIBRARY as pills (verified 2026-11-13)
- NEW: Steam stretches it to the full BottomBar height (`align-self: stretch`). Slate: 20px pill,
  `align-self: center`, centered text, 600 weight, 6px gap before the price.
- IN LIBRARY: same pill (999px radius) and inset `left: 8px` so it doesn't sit flush on the card edge.
- Verified via injected CSS: NEW r=999px h=20 align=center; IN LIBRARY r=999px left=8px; both Slate blue.
  Screenshot: docs/screenshots/pill-after.png (local only).
- Follow-up: Steam pins the price box (19px) to the top of the 28px BottomBar (block parent), so NEW
  and the price sat ~4px high. `[class*="SalePriceWidgetContainer"] { height:100%; align-items:center }`
  centers the row; `align-self` alone does nothing (parent is `display:block`). Verified: bar, pill and
  price midpoints identical.

## H1 — full-height Home hero (verified 2026-11-13)

| Stable selector | Steam | Slate |
|---|---|---|
| `.gamepadhome_RecentSection`, `.gamepadhomerecentgames_RecentGamesContainer` | 397px section | `min-height: 100vh` (What's New moves below the fold: 367 → 558) |
| `.gamepadhomerecentgames_RecentGamesBackgroundContainer` | 397px tall | `height: 100vh` |
| `…BackgroundContainer, …BackgroundImages` mask | radial(75% 83% at 50% 18%) | radial(110% 95% at 50% 22%), softer |
| `.gamepadhomerecentgames_RecentGamesBackgroundImage` | `brightness(50%)` | `brightness(80%)` |
| `.gamepadhomerecentgames_RecentGamesInnerContainer` | — | `padding-top: 13.5vh` |
| `.BasicUI .appportrait_InRecentGames.Focusable:focus` | `translateZ(15px)` | `+ scale(1.03)`, deeper shadow |
| `.gamepadhomerecentgames_RecentGamesContainer .marquee_Content` | 18px | 20px + text-shadow; width untouched (Steam's marquee) |

Lessons:
- Focus scale ceiling is set by the clipped virtualized carousel (~12px headroom). Measured
  8% → top clipped 3.8px + title overlap 3.7px; 4% → 0.5px; **3% → 1.5px spare** (outline animates up to ~3.3px).
  Bottom-origin scaling makes the top clipping worse; `overflow: visible` on the grid would break scrolling.
- Changing the title box width breaks Steam's marquee (duplicated, clipped text) — only change font-size.
- Steam has an unused `BigArtMode` (full-brightness art, linear mask) — similar intent, not enabled.
- Name check: every class in home.css resolves to exactly one CSS Loader translation entry.
Device: verified on LCD (Jupiter); OLED shares the 854×534 viewport. Controller down/up navigation to
What's New still to be confirmed by the user on hardware.

## H2 — hero transition, bigger covers, title spacing, play icon (verified 2026-11-13)

**Transition.** Steam's art animations (from library.css):
`.RecentGamesBackgroundImage { animation-duration:.3s }`; incoming
`.…Image.gamepadhomerecentgames_MoveRight:not(.gamepadhomerecentgames_OffScreen)` → keyframes
`from{transform:translateX(32px);transform:scale(1.03);opacity:0}` — **bug**: the second `transform`
overrides the first, so the directional slide never happens. Outgoing (`.OffScreen.MoveLeft/Right`) is
correct (`translateX(±32px) scale(1.08)` + fade). Slate: own keyframes `slate-art-in-from-{right,left}`
combining translate+scale, duration .5s; `.LowPerfMode` keeps .3s. Steam's 25s Ken Burns
(`gamepadhomerecentgames_RecentGamesBackground`) kept.

**Bigger covers.** `.gamepadhomerecentgames_RecentGamesContainer .basicgamecarousel_BasicGameCarousel
{ transform: scale(1.12); transform-origin: 0 0 }` — visual only; virtualized grid sizes untouched.
Hero padding 13.5vh → 9vh to make room. Title wrapper (`basicgamecarousel_CarouselGameLabelWrapper`)
padding-top 14 → 24px.

**Play icon.** `.basicgamecarousel_Play .basicgamecarousel_ActionIcon` (Steam: same selector, #59bf40)
→ `--slate-green-light`.

Verified via injected CSS: cards 163×244 (was 141×212), focus top room 1.1px (no clip), title gap
17.4px (was 1.5px), label bottom 458 < footer 492, icon rgb(91,191,138), art animation .5s.
Screenshot: docs/screenshots/h2-after.png (local only).

## G5 — Media + DLC (verified 2026-11-13)
`.appdetailsscreenshotssection_ScreenshotsSection .appdetailsscreenshotssection_Thumbnail` and
`.appdetailsdlcsection_DLCArt` → 8px + `overflow:hidden` (clips the image and DLC's absolute
`appdetailsdlcsection_Gloss` sheen). `.appdetailsdlcsection_Remainder` ("+N more") cool
rgba(103,112,123,.2) → `--slate-muted` 20%. Focus ring rounded while a thumbnail/DLC item has focus.
Verified via CDP on Expedition 33 (DOM loaded, off-screen): 3 thumbnails 8px/hidden with images
inside bounds; DLC art 8px/hidden with gloss inside. Not yet seen on device: Remainder box
(game had none) and the rounded ring on a focused thumbnail.

## Tooling — remote CSS Loader refresh
CSS Loader's Refresh button calls `reloadBackend()` → `callPluginMethod("reset")`. From the
SharedJSContext CDP target the same call is
`DeckyPluginLoader.createLegacyPluginAPI("CSS Loader").callPluginMethod("reset", {})`.
`tools/cssloader-refresh.mjs` does this; `deploy.sh` runs it after rsync.

## G6 — game page buttons + ProtonDB trend border (verified 2026-11-13)
- Buttons: Steam `button.DialogButton { border-radius: 2px }`, strongest
  `button.….DialogButton:enabled` (0,3,1). Slate: `.BasicUI .appdetails_ScrollContainer button.DialogButton(:enabled)`
  (0,4,1) → 8px. `DialogButton` is not a CSS Loader translation name (stays literal).
  "Manage my N items" / "View all my reviews" = `appdetailsbutton_AppDetailsButton.…_BottomRight`,
  cool #3d4450 → `--slate-control` (mirrors Steam's `:not(.gpfocus)` selector).
- ProtonDB trend: protondb-decky sets `border: 2px solid #4ade80|#f87171` + glow **inline** on the
  badge's wrapper div (improving/declining). Matched with `div:has(> .protondb-decky-indicator…)[style*="74, 222, 128"]`
  / `[style*="248, 113, 113"]` → Slate green/red, radius 10px; tier inset ring removed under a trend border.
Verified: wrapper radius 10px, border rgb(91,191,138); buttons 8px, Manage/View rgb(67,67,71).

## R1 — Home › Recommended (verified 2026-11-13)
Mostly embedded Steam **Store** UI; its classes are mostly absent from CSS Loader's table.
| Selector | Kind | Steam | Slate |
|---|---|---|---|
| `.gamepadhomerecommended_Recommended .carousel__inner-slide > *` | stable (pure-react-carousel BEM, literal) | square | 8px + overflow hidden |
| `… .tqaXEuWN2wV5_8lmSkMng:not(._8UPO4…):not(._1beaDt…)` | store hash, **fail-safe** | `._326_… .tqaX…` blue gradient rgba(31,49,74…) | neutral raised gradient |
| `.gamepadhomerecommended_DiscoveryQueueWidgetCtn` | stable | square | 8px + overflow hidden |
| `… ._3PAP1PfUymQrLEveRsxQxP`, `… ._1DaxYFphX9KPH-YWeuNTvO` | hashes that map to themselves in the table (tracked) | rgb(56,100,131) | `--slate-control` |
| `.gamepadhomerecommended_PlayNextCarousel .marquee_Content` | stable | 18px/800 (inherited) | 16px |
| `.basicgamecarousel_TextBoxCarouselContents` ("View more in your Library" end tile) | stable | square | 8px radius; added to the `:root:has` focus-ring list so the ring rounds too (verified on hardware 2026-11-14) |
| `.gamepadhomerecommended_Recommended .libraryassetimage_Container` | stable | rgb(14,20,27) | `--slate-surface` |
Event-colored calendar variants (pink, `_8UPO4…` / `_1beaDt…`) keep their colors (Steam event art), only rounded.
Verified via injected CSS: 14 plain calendar cards 8px + neutral; event cards 8px with own gradient; queue 8px,
body rgb(67,67,71); play-next title 16px; placeholders rgb(32,34,38).
Also: Home hero title 20px → 17px (rendered ≈19px under the carousel's scale(1.12); 20px rendered ≈22.4px).
- Calendar fit: with a calendar card focused, Steam scrolls it to start ~140–160px down; the
  two-game day card is 338px → bottom ~498 > footer top 492. `.gamepadhomerecommended_Recommended
  .carousel:has(.tqaX…) { transform: scale(.95); transform-origin: 0 0 }` (visual only; `carousel`
  is a literal pure-react-carousel class). Verified focused: tallest visible card top 140, h 321,
  bottom 461 (fits, 31px clear). Measure focused states *immediately* — pressing A opens the store.
- **Superseded:** the 95% `transform: scale()` calendar fit misaligned Steam's global focus ring
  (dx −26.8 to −28.2px, dw −12px): Steam positions `focusring_FocusRing` from layout, not from
  transformed rects. Rule: **never use transforms on containers whose items use the global focus ring**
  (Recent Games is fine — its cards draw their own outline). Replaced with a layout change:
  `.gamepadhomerecommended_Recommended .tqaX… img { height:122px; object-fit:cover }` → focused,
  ring offset dx=0 dy=0; tallest card 326px. Tiles 6px radius + ring 6px (`:root:has(.tqaX… .gpfocus)`).
- Steam scrolls the focused item into the full 534px viewport and ignores the 42px footer overlay,
  so items near the bottom can sit partly under the footer (Steam default behavior, not Slate).

## O1 — "Hero" option (CSS Loader v9 patch, verified 2026-11-13)
`theme.json` → `patches.Hero` (dropdown, default "Full"): Full injects `css/hero-full.css`
(section/container `min-height:100vh`, art `height:100vh`, inner padding 9vh, carousel `scale(1.12)`,
title 17px); Compact injects nothing. Carousel scale is Full-only (at Steam's 397px hero it would
reach the tabs). CSS Loader stores the choice in the theme's `config_USER.json`.
Verified by switching via `callPluginMethod("set_patch_of_theme",{themeName,patchName,value})`:
Full → section 0..588, tabs 558, cards 163×244, title 17px; Compact → section 0..397, tabs 367,
cards 141×212-class, title 18px, no carousel transform. Restored to Full.

## MM1 — main menu (STEAM button) (verified 2026-11-13)
Separate CEF page `MainMenu_uid2` → `theme.json` injects `css/tokens.css` + `css/mainmenu.css` into `MainMenu`.

**⚠ Two pitfalls specific to this page**
1. Steam's stylesheets load *after* CSS Loader's `<style>` here → equal specificity loses. All rules are
   prefixed with the page root `.BasicUI`.
2. **Multi-hash translation entries.** `css_translations.json` lists two hashes for `mainmenu_Item`
   (`_2w9TpQwx…` current, `_1LoZDVq2…` newer) and `mainmenu_ActiveDot` (`_1uLVHdii…` / `GxQrkK73…`);
   CSS Loader injects the **last** one, which this Deck's Steam doesn't use yet — any exact hash in the
   list gets rewritten too. Fix: `:is(.mainmenu_Item, [class*="2w9TpQwxU7vcwaAbf3KGv"])` (partial hash
   isn't a table name, so it stays literal). Drop the `[class*]` half after Steam updates.
   Scan result: only these two names are affected (`focusring_FocusRing` is multi-hash but its last hash is current).

| Stable name | Steam | Slate |
|---|---|---|
| `mainmenu_Menu` | `#0e141b`, flat | `--slate-bg`, radius 0 12 12 0, shadow 8px 0 32px |
| `mainmenu_ActiveDot` | `#1a9fff` | `--slate-blue` |
| `mainmenu_Item` | full-width rows; focused/active `scale(1.1)` from `transform-origin: 12% 50%`; hover/focus+hover rgba(255,255,255,.2) | inset 16px/30px (scaled row ~13px clear both sides), radius 8px, focus/hover pill rgba(244,244,245,.12) at 0,4,0 |
Verified: panel rgb(17,18,20), dot rgb(45,116,196), scaled active row clear L=13.7 R=12.9; open-menu screenshot.
Hidden CEF windows can't be screenshotted (no frames) — wait for the menu's open class `_3apLK4…` and for
its slide-in transform to finish.

## QA — Quick Access menu (verified 2026-11-13)
Page `QuickAccess_uid2` (854×454); Steam sheets load after CSS Loader's → `.BasicUI` prefix.
| Stable name | Steam | Slate |
|---|---|---|
| `quickaccessmenu_QuickAccessMenu`, `quickaccessmenu_Title` | `#0e141b` | `--slate-bg` |
| `quickaccessmenu_Menu::before/::after` (dividers) | `#23262e` | rgba(244,244,245,.08) |
| `quickaccessmenu_Tab` | square; selected rgba(255,255,255,.2), focused #fff | radius 8px (colors kept) |
| `button.DialogButton` in the menu | 2px | 8px (0,4,1 beats `:enabled` 0,3,1) |
| `.GamepadMode.friendlist`, `.multiChatDialog` (+`.gpfocuswithin`), `insetshadow_FriendListInsetShadowTop` | navy radial/linear gradients | same shapes, charcoal / surface |
`gamepaddialog_Field` and `gamepaddialog_ToggleRail` are multi-hash entries, but their last hash is the
current one on this Deck (no workaround needed). Verified: panel/title rgb(17,18,20), tabs 8px, dividers
neutral, toggles on-fill rgb(45,116,196), no navy left (scan of the open menu).

## A — accents on every page (`css/accents.css`, verified 2026-11-13)
Injected into bigpicture + MainMenu + QuickAccess.
- Steam accent variables (on `:root`) redefined on `.BasicUI`: `--color-blue-8`, `--left-track-color`
  (slider fill), `--color-progress-bar-foreground`, `--virtualmenu-accent`, `--virtualmenupointer-color`
  → `--slate-blue`. Left alone: `--status-color`, `--award-base-color` (may carry meaning).
  (Replaces the earlier achievements-only scoped re-point.)
- Toggles: `gamepaddialog_ToggleRail::before` #1a9fff → Slate blue; focused-row track #23262e → surface.
- Battery: `<rect fill="#59BF40">` presentation attribute → `svg rect[fill="#59BF40" i]` → Slate green.
  Only the green state matches; other charge colors untouched.
- Avatar presence (`steamavatar_avatarStatus`): `.GamepadMode .online …` #4cb4ff → `--slate-blue` (was light blue until v0.4.0; switched to match the main accent)
- Tab "new" dot (`gamepadtabbedpage_TabBadge` + variant `[class*="dMeP6nQOzmGaNM8EMLiSk"]`, e.g. What's New): #1a9fff → `--slate-blue`. Substring match on the untranslated variant hash so count badges are untouched; fails safe if renamed. Verified 2026-11-14.
  #6FA3DF (new token); `.ingame …` #59bf40 → `--slate-green-light`. Doubled class for 0,4,0.
  Offline (#67707b) and watching-broadcast (purple) kept.
- ProtonDB grid dots: SVG attrs `rgb(74, 194, 100)` / `rgb(200, 30, 30)` → Slate green / red.
Verified by a full-page color scan of all three pages: no Steam blue/green left except our own colors.
- **Sliders:** `gamepadslider_SliderTrack` (and hashed `._1AbErMQt…`) set `--left-track-color:#1a9fff` on the
  element itself, beating the inherited page-root value → overridden on the element (`.BasicUI` prefix).
- **Friends presence** (QuickAccess › Friends): Steam GamepadMode rules `.GamepadMode .online .personanameandstatus_playerName`
  #b3dfff, `… _richPresenceLabel/_gameName` and `friendsnooze_SnoozeZ` #4cb4ff, in-game #91c257/#a1f410,
  `.friendGroup.onlineFriends` border rgba(76,180,255,.3). Slate: names `--slate-blue-pale` #B9CFEA (new token,
  11.8:1), status `--slate-blue-light`, in-game `--slate-green-light`; doubled classes for 0,4,0+ (Steam loads after).
  Verified: online name rgb(185,207,234), status rgb(111,163,223); full scan of the open Friends tab finds no Steam blue/green.

## Notifications (`css/notifications.css`) — 2026-11-14
Injected into `bigpicture`, `QuickAccess` and `notificationtoasts_.*` (raw tab-title regex — CSS Loader
passes unknown inject keys through as `^(…)$` title matches; `tokens.css` is injected there too).
Toast windows have no `.BasicUI` root, so specificity uses `:root` + doubled classes.
Steam ships four copies of the notification templates (`standardtemplates_`, `shorttemplates_`,
`steamtemplates_`, `notificationcontent_`); each rule lists all four. All single-hash entries.

| Selector | Steam | Slate |
|---|---|---|
| `*_AvatarStatus.ingame` / `.online` (friend avatar strip) | #59bf40 / #4cb4ff (0,2,0) | `--slate-green-light` / `--slate-blue` (0,3,0) |
| `*_FriendInGameAppColor` ("Playing: <game>") | #91c257 (0,2,0) | `--slate-green-light` via `:root .X.X` |
| `*_NewIndicator svg` + `*_NewIndicator` filter (unread dot + glow) | #57a11c | `--slate-green-light`, glow at 80% |

Verified in Quick Access › Notifications on hardware; toasts not yet seen live.
Also: `quickaccessmenu_Title` navy glow `box-shadow: 0 0 7px 12px #0e141b` → same glow in `--slate-bg`
(it drew navy bands above/below the Quick Access title).

## Settings (`css/settings.css`) — 2026-11-14
Injected into `bigpicture`. Steam's cool blue-greys → Slate neutrals with the same layering.

| Selector | Steam | Slate | Verified |
|---|---|---|---|
| `.gamepadpage_GamepadPage.gamepadpage_DialogBackground` (S1, full-screen page shell) | navy radial | `--slate-canvas` | ✓ |
| `.gamepadpagedsettings_PagedSettingsDialog` / `…_ContentColumn` (S2) | #0e141b / #1a1c21 | `--slate-bg` | ✓ |
| `.gamepadpagedsettings_PagedSettingsDialog_PageListColumn` (S2, sidebar) | #2b2d33 | `--slate-surface` | ✓ |
| `…_PageListItem.gamepadpagedsettings_Active` / `:focus` (S3) | blue gradient .22/.40 + #1a9fff bar | neutral gradient .08/.16 + `--slate-blue` bar | ✓ |
| `.gamepaddialog_Field[class*="_2CCdODv0vfzOMrEBUzZwfI"]` (S4, boxed row; modifier `Background` has no stable name) | #23262e, square | `--slate-surface`, 8px (rows sit 6px apart) | ✓ |
| `PagedSettingsDialog button.DialogButton(:enabled)` (S5) | 2px | 8px (0,4,1) | ✓ |
| `networksettings_Checkmark`, `customizationsettings_Checkmark` (S6) | #59bf40 | `--slate-green-light` | ✓ |
| `contentmanagement_DriveUsage{Games,Workshop,FreeSpace,Indicator}`, Media `[class*="_2h-2O3n134sdwgtdM_Fuqr"]` (S7) | #1a9fff / #59bf40 / #3d4450 / cool stripes / #236c39 | Slate blue / green-light / control / neutral stripes / Slate green; DLC + shader purples kept (category colors are the information) | ✓ |
| `.libraryassetimage_GreyBackground` doubled (S7) | `.BasicUI` #0e141b (0,2,0) | `--slate-surface` (0,3,0) | ✓ |
| `gamepadslider_SliderNotchTick.gamepadslider_TickActive` (S8) | #1a9fff (0,2,0) | `--slate-blue` (0,3,0) | ✓ |
| `gamepaddialog_FieldDescription a` (S9) | #6dcff6 | `--slate-blue-light` | ✓ |
| `[class*="_3Vl2zkYPoCpw1q_1n28D3z"]` (S10, Downloads panel, `FakeContainer`) | #23262e | surface, 8px | ✓ |
| `[class*="_7EGqd8bdiXJBd2fj5Hh8r"]` + `MYyv…` active + `_1gKI…` pip (S11, Game Recording) | #23262e, cool overlays, #1a9fff pip | surface, neutral overlays .08/.14, `--slate-blue` pip | ✓ |
| `contentmanagement_Rule` ×3 (Storage divider; Steam 0,3,0) / GR unselected pip `[class*="_2sQtvR60AbFF5UzDwY9hit"]` | #67707b/.3 / #67707b | white .10 / `--slate-muted`; GR cards also 8px | ✓ |
| `familysharedcomponents_MeBadge` (S12) | #59bf40 + dark text | `--slate-green-light` + dark text | ✓ |

Focused dialog row (A7, `accents.css`): Steam sets #3d4450 *and* runs `ItemFocusAnim-darkGreySettings`
(fill-mode forwards, ends #383a41). Animations beat normal declarations, so the rule swaps
`animation-name` for `slate-row-focus` (surface → `--slate-control`, muted → white). Verified ✓.
Gotcha: when a color won't change although the rule wins the cascade, check `el.getAnimations()`.

## Downloads (`css/downloads.css`) — 2026-11-14
Injected into `bigpicture`. Network = blue, disk = green (as in Steam) → Slate versions; Steam's grey
paused/queued states keep their grey (meaning). Unnamed variants via hash substring.

| Selector | Steam | Slate | Verified |
|---|---|---|---|
| `.downloads_DownloadsPage` ×2 / `.downloads_Section` ×3 / `.Section.Empty [class*="_24D3…"]` (D1) | navy radial / #0e141b | canvas / `--slate-bg` | ✓ |
| `.downloads_Rule` ×2 (D1) | #67707b/.3 | white .10 | ✓ |
| `.downloads_PatchNotes`, `[class*="_1bZTWHCV…"]` (+ `MAz4…` Green) (D2) | #1a9fff (+ #59bf40) | `--slate-blue-light` (+ green-light) | ✓ |
| device picker `[class*="_1XjtfRHLm0…"] [class*="FmfZJt…"]` (D3) | #3d4450, focus #1a9fff + blue shine | control, focus `--slate-blue` + white shine | rest ✓, focus pending |
| `downloadgraph_GraphBarDownload` / `GraphLine` / `Network svg` / `Disk` (D4) | #1a9fff .5 / #59bf40 | Slate blue 75% / green-light | ✓ |
| `.downloads_ProgressBar` ×2 `:not([class*="_2Xedpg…"]) div` + variants `_2mLZnQ…` (downloading), `HifZB5…` (disk) (D5) | #1a9fff / .5 / #59bf40; grey paused | Slate blue / 75% / green-light; grey kept | ✓ |
| `.downloads_SectionItem .downloads_Button.DialogButton:enabled` + active variant (D6) | #3d4450 / #1a9fff | control / `--slate-blue` (focus white left to Steam) | ✓ |
| `.downloads_SectionItem.downloads_Active` (+ focused) (D7) | #0e141b (#3d4450) | `--slate-surface` card (control) | ✓ (focus pending) |
| `downloadgraph_HeroGradient` → none + mask on `downloadgraph_HeroAndLogo` (D7) | multiply → rgb(0,86,214) (blue tint on art) | art fades to transparent (mask 45%→100%) into the card | ✓ |
| `downloads_SectionList.downloads_DropOption.downloads_DragOver` (D7) | blue radial | Slate-blue radial | not seen |
| `header_HeaderDownloadProgressBar` (D8, top bar) | #1a9fff (0,4,0) | `--slate-blue` | ✓ |

**D9 layout (2026-11-14, verified on hardware):** active download = inset card — TopSection
`[class*="_373v1eWNyaPKhgnea9FZSt"]` padding 48px 12px 4px + `box-shadow: none` (Steam's full-width
shadow), card radius 12px + own shadow, HoverRing `[class*="_3B3J2qtE6ozU_VXMMN2L51"]` 12px,
`downloads_TopBar` (1px white .1 rule at the seam) hidden; device label RemoteClientManagementRow/
Background → glass pill at the card's corner; `downloads_Title`/`Count` tracking 1px → 0 (title 500);
progress bars 6px fully rounded; item buttons + Clear All 8px; rows 8px; thumbnails
(`.downloads_SectionItem .appportrait_LibraryItemBox`, 0,3,0 vs Steam's overflow:visible 0,2,0) 6px.
Tooling note: CDP preview CSS must be run through a name→hash translation (scratchpad translate.mjs)
— raw stable names only work after CSS Loader injects them.

## Store (`css/store.css`) — 2026-11-14
Injected into CSS Loader's `store` target (store.steampowered.com / steamcommunity.com tabs; `tokens.css`
too). Scoped to `html.client.GamepadMode` (the desktop client's store is untouched). The store is a
website: classes are unhashed long-lived names (checked: none collide with CSS Loader translation
names) plus a few store React hashes (`XLbP8xOkCYw-` nav, `bXqaBMkoZYQ-` focus ring, `maxz19gKOQc-`
calendar card, `x8jWPgfdVoI-` NEW chip) matched by substring — fail safe. Review-score colors kept.
Light pass: home page only; purchase/checkout not targeted. Verified on hardware (full-page capture
via `captureBeyondViewport`, no UI scrolling).

| Selector | Steam | Slate |
|---|---|---|
| `body` (ST1) | #0f1924 | `--slate-bg` |
| `.store_main_capsule` / `.info` (ST2) | square / blue gradient + inner blue glow | 8px / neutral gradient, no glow |
| `.ds_steam_deck_compat` / `.ds_flag.ds_wishlist_flag`, `.ds_owned_flag` (ST3) | navy glass / #03628b, #4f95bd | `--slate-glass` / `--slate-blue` |
| nav `[class*="XLbP8xOkCYw-"]` (ST4) | navy radial | surface radial |
| focus ring `[class*="bXqaBMkoZYQ-"]` while a `.store_main_capsule` is focused (ST5) | square | 8px |
| `.sale_capsule :is(.creator_capsule_ctn, .deep_dive_key_tags, .recently_updated_desc)`, `.home_discount_games_ctn`, `.community_recommendation_app`, calendar `[class*="maxz19gKOQc-"]`, `.tab_row_item.focus` (ST6) | blue radials/gradients, #000f18, cool .25 | neutral equivalents |
| NEW chip `[class*="x8jWPgfdVoI-"]`, `.LoadingThrobber .Bar` (ST7) | #1a9fff, #67c1f5 | `--slate-blue`, `--slate-blue-light` |

Left as-is: category tiles (`content_hub_capsule_ctn .gradient` — the color is the category art), two
unidentified store-hash widgets (`jxYpM-g5fRs-` teal gradient, `hjG2apu1gQc-`).

## On-screen keyboard (`css/keyboard.css`) — 2026-11-14
Injected into `bigpicture`. Default theme only: Steam drives it with variables on
`.virtualkeyboard_Keyboard.DefaultTheme` (0,2,0) → redefined at `.BasicUI …` (0,3,0): panel #23262e →
surface, keys #0e141b → `--slate-bg`, modifiers #000 → `--slate-bg-deep`, focused-key dark text navy →
charcoal, extended keys / toggles / pointer #1a9fff → `--slate-blue`, one-shot + dead-key accents →
`--slate-blue-light`, emoji highlight #3d4450 → control. Pressed-key flash (literal #1a9fff, 0,4,0) →
`--slate-blue` at 0,5,0. Text preview bar `virtualkeyboardcontainer_VirtualKeyboardTextBuffer` #151f25 →
surface. Points Shop keyboard themes untouched. Injection verified (translated selector present);
visual check pending (keyboard can't be opened remotely).

### Store game pages + dialogs (ST8–ST12) — 2026-11-14
New store React UI: classes are store CSS-module hashes (suffix `-`), all matched by substring (fail
safe). ST8 overrides the store's own color variables (`--color-greyneutral-2/4/6/8`, `--color-blue-8`;
only ~12 rules use them, cheap and robust). ST9: `.DialogContent` charcoal + neutral edge, 12px;
Deck Compatibility dialog forces `#0e141b !important` on `.DeckVerifiedModalDialog(Client) .DialogContent._DialogLayout`
→ answered with `!important` (Slate's rule: only against Steam's own !important / inline); scroll fades
`Z8zypUObkYE-` ::before/::after. ST10: info panels `alRCY87ae-s-`, purchase box `icJTR-r-wDw-`, price row
`[class*="SalePriceWidgetContainer"]` inside it, compat tab pills `AYShSUpazpQ-` excluding the active
modifier `Tw-TchJW1T8-` and `.gpfocus` (a first attempt beat Steam's white active pill → dark icon on
dark). ST11 tag chips `bEoYeP62vKg-` → neutral pills. ST12 links/text `oDEFTUumdv8-`, `GeWSoC6e568-`,
"40 FPS" `WGUFkBLPn8E-` + chevron `heKA7rr02xo-` → light Slate blue; `S0TPsOpik3c-` ("Learn more"),
`QilvZ2g5iKM-` → Slate blue. Kept: prices, discount green, review scores, Deck-compat status colors,
ProtonDB tier badge. Collisions found and avoided: `StoreSalePriceWidgetContainer`,
`StoreSaleDiscountBox`, `ActiveTab`, `v6` are CSS Loader translation names.
Verified on hardware (dialog + full game page via full-page capture).

### Store palette variables + game page polish (ST0, ST13) — 2026-11-14
~20 store stylesheets are cross-origin (CDP can't read their rules), but they resolve the store's Gaming
Mode palette on `html`: `--gpBackground-{DarkHard,DarkMedium,DarkSoft,DarkSofter,LightSofter,LightSoft,
LightMedium,LightHard}`, `--gpStore{Darkest,Darker,Dark,,Light}Grey`, `--gpGradient-StoreBackground`,
`--gpColor-{Blue,BlueHi,ChalkyBlue,DustyBlue,Green,GreenHi}` → overridden (ST0) with neutral/Slate values
of the same lightness/alpha. Red/Orange/Yellow kept. Values are read with
`getComputedStyle(html).getPropertyValue(name)` (custom props don't enumerate). ST13 rounds and
neutralizes the game page: media frames `zveLzqpea5Q-`, purchase boxes `FneGtSBNXCI-`, DLC rows
`k4U-U7-NtBA-`, `.OtherEvents_EventCtn`, sidebar rows `vEPSMT4v-yc-`/`RAdU2xWu3-4-`, relevance tags
`_3qdZjzvKgfw-`, panels `yDw9gqlgbxM-`/`dA19VXylzCQ-`/`jzzyZV9Ndlw-`/`ftI4LxM9C-k-`, buttons
`j8iZOirRLc8-` + legacy `.btnv6_blue_hoverfade`, price block `ZLlm68-AqhM-`, capsules `mspnwaz0EAg-`
(**`CapsuleImageCtn` collides** with a translation name), Metacritic `LXuyTO7ejPo-` (color kept).
Text: generic blue text `oDEFTUumdv8-` → neutral #c7c9cd (Steam colors the whole review line one blue
regardless of score, so it isn't score information), headers muted, title white, links light Slate
blue, body text #ccd8e3 → #d4d6d9; score-coded `.ddSW8NTrpmA-` kept. Trailer progress: only the played
part (`eBjRkRA8NpA-`) → Slate blue.

## Search (`css/search.css`) + Game Properties (S13) — 2026-11-14
Search: `.gamepadsearch_GamepadSearch` navy radial → canvas; `.gamepadsearch_ResultTemplateImage` 8px
+ focus ring rounded via `:root:has(… ResultTemplate(Image).gpfocus)`. Verified.
Game Properties reuses the paged settings dialog (S1–S5 apply). Per-tab (scanned all 9 tabs):
`appproperties_BlueHighlight` #1a9fff → light Slate blue; `appproperties_SectionTopLine` cool → neutral;
`appproperties_SteamInputStatusGrid` cool .2 → neutral 8px; connected `appproperties_ControllerPip`
#3a7fd5 → Slate blue (0,7,0 vs 0,6,0); betas table (no stable names: `_3jWpi0kJp…` table, `X3pN_ESh…`
header, `_1LCoWsUr…` rows with `_2fy9…`/`_231y…` stripes, `_2d_FE9TO…` radio) → neutral, rounded, Slate-blue
selected bar. Steam's high-contrast (black/white) variants left alone. Verified.
Not reachable by route: Friends & Chat (`/friends` renders empty — separate web view); check when the
user opens it from the menu. Media renders only when opened from the menu (route `/media/grid`).

## Media (`css/media.css`) — 2026-11-14
Screenshots/recordings grid. Colors already neutral; shape only. No stable names: item
`[class*="_2-7fqz03LhYHKEBI-HwIPq"]` (wEPhzApt_ListItem — draws its own 2px white focus border) → 10px;
thumbnail `[class*="_2hcrnBEslc1Awh2IFpGA7W"]` → 8px inside it. Verified on hardware (focused item).

