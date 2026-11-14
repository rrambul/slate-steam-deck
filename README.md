# Slate

A minimal, clean CSS Loader theme for the Steam Deck Home screen.
"The games are the artwork. The interface should disappear."

## Requirements
- SteamOS (tested on 3.9.5), Decky Loader, CSS Loader 2.1.3 (manifest v9)

## Devices
| Device | Status |
|---|---|
| Steam Deck LCD (Jupiter) | developed and verified on hardware |
| Steam Deck OLED (Galileo) | expected to match: same 1280×800 panel / 854×534 Gaming Mode viewport; not yet verified on hardware |
| Docked / external display | layout uses viewport units (`vh`) for the hero; not yet verified |

Charcoal (`#111214`) is intentionally not pure black, which avoids OLED black smearing.

## SSH setup
`deploy.sh` connects to the SSH host `steamdeck`. Add an entry like this to
`~/.ssh/config` (key-based auth; enable `sshd` on the Deck first):

```sshconfig
Host steamdeck
    HostName <deck-ip>          # or steamdeck.local
    User deck
    IdentityFile ~/.ssh/<your-deck-key>
    IdentitiesOnly yes
```

To use a different host alias: `SLATE_HOST=myhost ./deploy.sh`

## Deploy
```sh
./deploy.sh
```
Copies `theme.json` and `css/` to `~/homebrew/themes/Slate/` on the Deck
(repo tooling, docs and LICENSE are excluded), then refreshes CSS Loader automatically
if Node 22+ is installed and Decky's **Allow Remote CEF Debugging** is enabled
(`tools/cssloader-refresh.mjs`). Otherwise: CSS Loader → Refresh. Enable **Slate** once.

Remote CEF debugging exposes the Steam UI on your network — turn it off when you're done,
especially on untrusted networks.

## Options
In CSS Loader, open **Slate** to choose:
| Option | Values |
|---|---|
| Hero | **Full** (default): Recent Games fills the screen, larger covers · **Compact**: Steam's hero height, What's New visible right away |

## Structure
```
theme.json          CSS Loader manifest (v9) — injects css/* into Gaming Mode (bigpicture, MainMenu, QuickAccess, notification toasts)
css/tokens.css      design tokens (--slate-*): palette, canvas gradient, radius
css/canvas.css      global charcoal canvas
css/home.css        Home rows, cards, hero styling shared by both options, focus ring
css/hero-full.css   Hero = Full: full-screen layout (patch, injected only when selected)
css/library.css     Library background, placeholders, cards
css/gamepage.css    game details page: backgrounds, action button, controls, activity
css/settings.css    Settings (and the shared full-screen page shell)
css/downloads.css   Downloads page + top-bar download progress
css/plugins.css     third-party Decky plugin badges (protondb-decky, playcount-decky)
css/mainmenu.css    STEAM-button side menu (injected into the MainMenu page)
css/quickaccess.css Quick Access menu (… button; injected into the QuickAccess page)
css/notifications.css  notification list + toasts (friend presence, unread dot; also injected into toasts)
css/accents.css     Steam blue/green accents → Slate colors on all pages
docs/selectors.md   every selector, why it was chosen, and how it was verified
deploy.sh           rsync deploy to the Deck
```
Selectors use CSS Loader's stable class names (e.g. `appportrait_InRecentGames`), which it
translates to Steam's hashed classes at injection time.

## Status
v0.4.0 — Home (incl. Recommended, with a Full/Compact hero option), Library, game page, main menu and Quick Access on neutral charcoal; Slate blue/green accents everywhere (toggles, sliders, progress bars, battery, friends presence); ProtonDB tiers keep their own colours; glass plugin badges; all cards rounded. See docs/selectors.md.

## Versioning
[Semantic Versioning](https://semver.org/): `0.x` during development, `1.0.0` for the first
DeckThemes release. See [CHANGELOG.md](CHANGELOG.md); releases are tagged `vX.Y.Z`.

## License
[MIT](LICENSE). Slate ships CSS only — no Steam, game or plugin assets. Screenshots used during
development contain third-party game art and are intentionally not part of this repository.
