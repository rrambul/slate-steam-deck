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
(repo tooling, docs and LICENSE are excluded). Then CSS Loader → Refresh, and enable **Slate**.

## Structure
```
theme.json          CSS Loader manifest (v9) — injects css/* into Gaming Mode (bigpicture)
css/tokens.css      design tokens (--slate-*): palette, canvas gradient, radius
css/canvas.css      global charcoal canvas
css/home.css        Home rows, cards and focus ring
css/library.css     Library background, placeholders, cards
css/gamepage.css    game details page: backgrounds, action button, controls, activity
css/plugins.css     third-party Decky plugin badges (protondb-decky, playcount-decky)
docs/selectors.md   every selector, why it was chosen, and how it was verified
deploy.sh           rsync deploy to the Deck
```
Selectors use CSS Loader's stable class names (e.g. `appportrait_InRecentGames`), which it
translates to Steam's hashed classes at injection time.

## Status
Home, Library and game page on neutral charcoal; Slate blue Install + Slate green Play; glass plugin badges; all Home card rows and Library cards rounded. Home neutralized (only blue left: small status badges). See docs/selectors.md.

## License
[MIT](LICENSE). Slate ships CSS only — no Steam, game or plugin assets. Screenshots used during
development contain third-party game art and are intentionally not part of this repository.
