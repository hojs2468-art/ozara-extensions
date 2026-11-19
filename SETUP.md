# Setting up your extension store (one time, ~5 minutes)

This folder **is** your store. You upload it to a new public GitHub repo once, and from then on it runs itself — people submit extensions by pull request, a bot publishes them, and Ozara shows them. **Your computer never has to be on.**

## 1. Make the repo

1. On GitHub, click **New repository**.
2. Name it exactly **`ozara-extensions`** (that's what the app looks for).
3. Set it to **Public** (it has to be — see "Why public?" below).
4. Don't add a README (this folder already has one). Click **Create**.

## 2. Upload this folder

Easiest in the browser:
1. On the new empty repo page, click **uploading an existing file**.
2. Drag in **everything inside this folder** (the `extensions`, `dist`, `.github` folders and the `.md` / `.txt` files). Keep the folder structure.
3. Write "first commit" and click **Commit changes**.

> The `.github` folder holds the bots. If GitHub hides it when dragging, that's a browser quirk — uploading the whole folder in one drag keeps it. If it still won't upload, use GitHub Desktop or drag the `.github` folder in as a second upload.

## 3. Let the bot push

1. In the repo, go to **Settings → Actions → General**.
2. Scroll to **Workflow permissions**, choose **Read and write permissions**, Save.

That's it. The store is live. Open Ozara → **Extensions → ⭐ Browse the store** and you'll see Styles, Themes and Quick Launch.

## How people add extensions (automatic)

They fork the repo, add a folder `extensions/<their-id>/` with their files, and open a **pull request**. Then it runs itself:

1. The **checker bot** validates the submission.
2. If it passes, the **auto-merge bot** merges it — no tap from you.
3. The **build bot** zips it and rebuilds the store.

So a submission goes from pull request to live in the store with **no action from you**.

**The one exception:** a person's *very first* submission waits for you to merge it (a quick look, one tap — the GitHub phone app works from anywhere). Everyone who's had an extension accepted before is fully automatic from then on. This stops a brand-new throwaway account from auto-publishing instantly.

### Make it 100% automatic (optional)

If you want *every* submission auto-merged, including first-timers:
1. Go to **Settings → Secrets and variables → Actions → Variables** tab.
2. **New repository variable**, name `AUTO_MERGE_ALL`, value `true`.

To go back to holding first-timers, set it to `false` or delete it.

## Blocking a bad actor

- Add their id or `author: TheirName` to **`blocklist.txt`** — the bots refuse them.
- Or **delete their extension's folder** under `extensions/`.
- Or **block the user** on GitHub (their profile → Block user).

## Rate limiting & spam

- The checker bot caps how many extensions **one author** can add (default **8**). To change it, edit `MAX_PER_AUTHOR` at the top of `.github/scripts/common.py`. Updating your own existing extensions is never blocked by this.
- Each pull request may add only **one** extension, so nobody can bulk-dump a batch.
- For a spam wave from brand-new accounts, GitHub has a one-click switch: **Settings → Moderation → Interaction limits → Limit to existing users** (temporarily blocks accounts that haven't contributed before). Turn it off when the wave passes.
- The per-author cap uses the name in the manifest, so it's a speed bump, not a wall — the Interaction limits + Block user above are your real tools against a determined spammer.

## Why public?

Ozara downloads the list with no login, so a private repo would mean putting a secret key inside the app — which anyone could extract. And people can only submit to a repo they can see. There's nothing secret here anyway: it's just a list of community extensions, all sandboxed.
