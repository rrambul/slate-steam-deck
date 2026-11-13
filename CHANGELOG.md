# Changelog

All notable changes to Slate. Versions follow [Semantic Versioning](https://semver.org/):
`0.x` while the theme is in active development; `1.0.0` will be the first DeckThemes release.
The version lives in `theme.json` (shown by CSS Loader) and as a git tag `vX.Y.Z`.

## [Unreleased]
### Added
- **Hero** option in CSS Loader (Slate › Hero): **Full** (default — full-screen Home hero,
  covers +12%) or **Compact** (Steam's hero height, What's New visible without scrolling).
  Shared hero styling (art, transition, focus, colors) applies to both.
- **Main menu** (STEAM button, new `MainMenu` injection target): charcoal floating sheet with a
  rounded edge and shadow, Slate-blue active-page dot, soft rounded focus/hover pill.
- **Quick Access** (… button, new `QuickAccess` target): charcoal panel and title, neutral dividers,
  rounded tab highlights and buttons; Friends tab gradients in charcoal.
- **Accents everywhere** (`css/accents.css`, all pages): Steam's accent variables (sliders, progress
  bars, menu accents) and toggle switches → Slate blue; battery icon green → Slate green (low-charge
  colors untouched); avatar presence online → light Slate blue, in-game → Slate green.
- ProtonDB library grid dots: working/not working → Slate green/red.
- Friends list presence: online names → pale Slate blue, online status/snooze → light Slate blue,
  in-game → Slate green; slider tracks (which set their own fill variable) → Slate blue.

## [0.3.0] — 2026-11-13
Verified on Steam Deck LCD, SteamOS 3.9.5, CSS Loader 2.1.3.
### Added
- Home › Recommended: rounded calendar, event and Discovery Queue cards; calendar Steam-blue
  gradient and Discovery Queue blue body → neutral; lighter "Play next" titles (16px).
- Home › Recommended: Personal Calendar day cards shortened (tile art 133 → 122px, cropped) so a
  focused card fits above the footer; tiles rounded (6px, nested in the 8px card) with a matching
  focus ring. (A 95% scale was tried first and dropped: it misaligned Steam's focus ring by ~27px.)
### Changed
- Home hero title 20px → 17px (≈19px on screen with the carousel's 1.12 scale).
- Game page buttons (`DialogButton`: Manage items, View reviews, New Note…) rounded to 8px;
  cool background → neutral control grey.
- ProtonDB trend border (green = improving, red = declining) kept, but rounded to wrap the
  badge and recolored to Slate green/red; the badge's own tier ring is hidden while it shows.

## [0.2.0] — 2026-11-13
First tagged release. Verified on Steam Deck LCD, SteamOS 3.9.5, CSS Loader 2.1.3.

### Added
- **Design tokens** (`css/tokens.css`): charcoal palette, Slate blue/green, status accents,
  glass/raised/control surfaces, shared canvas gradient, 8px card radius.
- **Global canvas**: Steam's navy gradient → neutral charcoal (Home, Library, game page).
- **Home**
  - Full-height hero: Recent Games and its art fill the screen; What's New below the fold.
  - Brighter art (50% → 80%), softer mask, directional art transition (fixes Steam's
    broken slide-in keyframes), 0.5s crossfade.
  - Recent Games covers +12%, focused card +3%, more space above the title.
  - Rounded cards in every row; rounded focus ring on those rows.
  - Navy tints neutralized; NEW / IN LIBRARY as Slate-blue pills; play icon in Slate green.
- **Library**: charcoal canvas, neutral placeholders, rounded cards.
- **Game page**
  - Neutral backgrounds; Slate-blue Install/Update, Slate-green Play.
  - Rounded action button, controls, info rows, activity/community cards, link buttons,
    Deck Verified box, media thumbnails and DLC art.
  - Achievements progress bar and Deck Verified check in Slate colors.
- **Plugin badges** (protondb-decky, playcount-decky): dark glass, rounded; ProtonDB tiers
  keep their own colors.
- **Tooling**: `deploy.sh` (rsync) with automatic CSS Loader refresh via
  `tools/cssloader-refresh.mjs`; CSS split into `css/` modules; `docs/selectors.md`.

## [0.1.0] — 2026-11-13 (untagged)
- Project scaffold: CSS Loader manifest v9, empty `shared.css`, deploy script.
