# Slate

A minimal, clean CSS Loader theme for Steam Deck Gaming Mode: Home, Library, game pages, Settings,
Store, menus, keyboard and more.
"The games are the artwork. The interface should disappear."

## Requirements
- SteamOS (tested on 3.9.5 stable and 3.9.6 beta), Decky Loader, CSS Loader 2.1.3 (manifest v9)

## Devices
| Device | Status |
|---|---|
| Steam Deck LCD (Jupiter) | developed and verified on hardware |
| Steam Deck OLED (Galileo) | untested (same 1280×800 resolution and Gaming Mode viewport as the LCD, so it should match) |
| Docked / external display | untested (the hero is sized in viewport units, other screens follow Steam's layout) |

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
| Keyboard | **Slate** (default): charcoal keyboard with Slate accents · **Steam**: Steam's default keyboard look |

## Structure
```
theme.json          CSS Loader manifest (v9) — injects css/* into Gaming Mode (bigpicture, MainMenu, QuickAccess, notification toasts, store)
css/tokens.css      design tokens (--slate-*): palette, canvas gradient, radius
css/canvas.css      global charcoal canvas
css/home.css        Home rows, cards, hero styling shared by both options, focus ring
css/hero-full.css   Hero = Full: full-screen layout (patch, injected only when selected)
css/library.css     Library background, placeholders, cards
css/gamepage.css    game details page: backgrounds, action button, controls, activity
css/settings.css    Settings + Game Properties (and the shared full-screen page shell)
css/downloads.css   Downloads page + top-bar download progress
css/store.css       Store home (Gaming Mode only; light pass on the website)
css/keyboard.css    on-screen keyboard (Default theme only; Keyboard option)
css/search.css      top-bar search results
css/media.css       Media (screenshots & recordings grid)
css/contextmenu.css game context menus (≡ Options)
css/plugins.css     third-party Decky plugin badges (protondb-decky, playcount-decky)
css/mainmenu.css    STEAM-button side menu (injected into the MainMenu page)
css/quickaccess.css Quick Access menu (… button; injected into the QuickAccess page)
css/notifications.css  notification list + toasts (friend presence, unread dot; also injected into toasts)
css/accents.css     Steam blue/green accents → Slate colors on all pages
docs/selectors.md   every selector, why it was chosen, and how it was verified
docs/deckthemes-checklist.md  DeckThemes submission requirements audit
docs/deckthemes-listing.md    DeckThemes listing text (description, options)
deploy.sh           rsync deploy to the Deck
```
Selectors use CSS Loader's stable class names (e.g. `appportrait_InRecentGames`), which it
translates to Steam's hashed classes at injection time.

## Status
v1.0.0, the first DeckThemes release. Slate styles every Gaming Mode screen CSS Loader can reach:
- Home (Full / Compact hero), Library, game pages
- Settings and Game Properties, Downloads, Search, Media
- Store (home, game pages, wishlist, categories)
- STEAM menu and in-game pages (Achievements, Guides, Notes), Quick Access, Friends & Chat
- context menus, the on-screen keyboard, notifications

Neutral charcoal, rounded shapes, Slate blue and green accents. Colours that carry meaning (ProtonDB
tiers, review scores, warnings, sale branding) are kept. Not themeable: the controller layout editor.
See docs/selectors.md.

## Versioning
[Semantic Versioning](https://semver.org/): `1.0.0` is the first DeckThemes release; fixes bump the patch
version, new options the minor version. See [CHANGELOG.md](CHANGELOG.md); releases are tagged `vX.Y.Z`.

## License
[MIT](LICENSE). Slate ships CSS only — no Steam, game or plugin assets. Screenshots used during
development contain third-party game art and are intentionally not part of this repository.
