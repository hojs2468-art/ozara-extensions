# Submit an extension to the Ozara store

Anyone can add an extension. You add **your own folder**; the bot checks it and, once it's merged, it shows up in Ozara's store automatically. You can't touch anyone else's extension.

## What you need

An extension is a folder with:
- `manifest.json` — its name, id, version, author, and which permissions it needs
- `main.luau` — the code

See the `extensions/ozara.quicklaunch/` folder here for a tiny example, and the full API docs in the main Ozara repo's `EXTENSIONS.md`.

## Steps (all in your browser)

1. **Fork** this repo (top-right "Fork" button) — that's your own copy.
2. In your fork, create a folder `extensions/<your-id>/`. Your id should be lowercase like `yourname.coolthing`, and the **folder name must match the id** inside your `manifest.json`.
3. Add your `manifest.json` and `main.luau` (and any `.png`/`.wav` assets).
4. Open a **Pull Request** back to this repo.
5. A bot checks it in a minute. If something's wrong, it tells you what to fix. If it passes, it **merges automatically** and the store rebuilds itself — your extension appears in Ozara. (Your very first submission gets a quick look from a maintainer before it goes live; after that you're automatic.)

## Rules the bot enforces

- One new extension folder per pull request.
- The folder name matches the `id` in your `manifest.json`.
- `manifest.json` has every required field and its `main` script exists.
- You don't change or delete anyone else's folder.
- One author can have at most a set number of extensions (8 by default). Updating your existing ones is always fine.

## Good to know

- Extensions run in a **locked sandbox**: no file access, no running programs, no touching Roblox. Keep that in mind — anything outside the `ozara.*` API won't work, by design.
- Only these file types are packaged: `.luau`, `.json`, `.md`, `.txt`, `.png`, `.jpg`, `.jpeg`, `.wav` (plus a few audio/font types inside a `mods/` folder).
- Keep it under 10 MB.
