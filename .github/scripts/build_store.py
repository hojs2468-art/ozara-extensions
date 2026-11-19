"""Build bot: zip every extensions/<id>/ into dist/<id>.ozext and write
dist/store.json. Runs on GitHub after each merge; safe to run locally too."""
import json, os, sys, zipfile
from common import EXT_DIR, DIST_DIR, RAW_BASE, ALLOWED_FILE_EXT, read_manifest, load_blocklist

def main():
    os.makedirs(DIST_DIR, exist_ok=True)
    blocked_ids, blocked_authors = load_blocklist()
    entries, built = [], []
    for name in sorted(os.listdir(EXT_DIR)):
        folder = os.path.join(EXT_DIR, name)
        if not os.path.isdir(folder):
            continue
        m, err = read_manifest(folder)
        if err:
            print(f"skip {name}: {err}")
            continue
        if m["id"] in blocked_ids or str(m["author"]).lower() in blocked_authors:
            print(f"skip {name}: blocked")
            continue
        # Zip the folder's allowed files into dist/<id>.ozext (manifest at the root).
        ozext = os.path.join(DIST_DIR, f"{m['id']}.ozext")
        with zipfile.ZipFile(ozext, "w", zipfile.ZIP_DEFLATED) as z:
            for root, _, files in os.walk(folder):
                for f in files:
                    ext = os.path.splitext(f)[1].lower()
                    if ext not in ALLOWED_FILE_EXT:
                        continue
                    full = os.path.join(root, f)
                    rel = os.path.relpath(full, folder)
                    z.write(full, rel)
        entries.append({
            "id": m["id"],
            "name": m["name"],
            "author": m["author"],
            "version": m["version"],
            "description": m["description"],
            "permissions": m["permissions"],
            "url": f"{RAW_BASE}/{m['id']}.ozext",
        })
        built.append(m["id"])
    entries.sort(key=lambda e: e["name"].lower())
    with open(os.path.join(DIST_DIR, "store.json"), "w", encoding="utf-8") as f:
        json.dump({"extensions": entries}, f, indent=2)
        f.write("\n")
    print(f"Built {len(built)} extension(s): {', '.join(built)}")

if __name__ == "__main__":
    main()
