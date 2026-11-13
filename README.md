# Slate

A minimal, clean CSS Loader theme for the Steam Deck Home screen.
"The games are the artwork. The interface should disappear."

## Requirements
- SteamOS (tested on 3.9.5), Decky Loader, CSS Loader 2.1.3 (manifest v9)

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
Copies `theme.json` and `*.css` to `~/homebrew/themes/Slate/` on the Deck
(repo tooling and docs are excluded). Then CSS Loader → Refresh, and enable **Slate**.

## Status
M3 in progress — charcoal canvas, rounded Recent Games and What's New cards. See docs/selectors.md.
