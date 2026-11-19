# Ozara Extensions

The community extension store for [Ozara](https://github.com/hojs2468-art/OzaraUpdater), a free, safe Roblox launcher. Browse and install these from inside Ozara: **Extensions → ⭐ Browse the store**.

## Want to add your own?

See **[CONTRIBUTING.md](CONTRIBUTING.md)**. Short version: fork, add a folder `extensions/<your-id>/` with your `manifest.json` + `main.luau`, open a pull request. A bot checks it and the store updates itself once it's merged — no one can edit or delete anyone else's extension.

## How it works

- Each extension is a folder under `extensions/`, named by its id.
- A bot checks each pull request, auto-merges it if it passes (first-timers get a quick manual look), then another bot zips it into `dist/<id>.ozext` and rebuilds `dist/store.json`.
- Ozara reads `dist/store.json` and downloads the packages from `dist/`.

Everything runs on GitHub's servers — nothing here needs a computer left on.

## Safety

- Every extension runs in Ozara's **locked sandbox**: no file access, no processes, no reaching into Roblox.
- `blocklist.txt` lets the maintainer ban a bad id or author; the bots refuse them.
- The maintainer can remove any extension by deleting its folder.
