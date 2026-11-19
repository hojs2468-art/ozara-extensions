"""PR check: a submission may only add/edit ONE extension folder, named by its
id, and may not touch anyone else's. Run with the list of changed files (one
"STATUS\tpath" per line) on stdin, as the workflow provides."""
import os, sys
from common import EXT_DIR, ROOT, MAX_PER_AUTHOR, read_manifest, load_blocklist, count_by_author

def fail(msg):
    print(f"::error::{msg}")
    print(f"\n❌ {msg}")
    sys.exit(1)

changed = []
added_manifest = set()  # folders whose manifest.json is newly ADDED => new extension
for line in sys.stdin:
    line = line.rstrip("\n")
    if not line.strip():
        continue
    parts = line.split("\t")
    status, path = parts[0], parts[-1]
    changed.append((status[0], path))  # A/M/D/R...
    norm = path.replace("\\", "/")
    if status[0] == "A" and norm.endswith("/manifest.json"):
        bits = norm.split("/")
        if len(bits) >= 3 and bits[0] == "extensions":
            added_manifest.add(bits[1])

if not changed:
    fail("This pull request doesn't change any files.")

# Everything must live under extensions/<something>/ ...
touched_folders = set()
for status, path in changed:
    norm = path.replace("\\", "/")
    # Allow the author to edit their own folder only; nothing else in the repo.
    if not norm.startswith("extensions/"):
        fail(f"Pull requests may only add files under extensions/. This one changes \"{path}\".")
    parts = norm.split("/")
    if len(parts) < 3:
        fail(f"\"{path}\" isn't inside an extension folder (extensions/<your-id>/...).")
    touched_folders.add(parts[1])

# ... and only ONE extension folder.
if len(touched_folders) != 1:
    fail("A pull request may only add or change ONE extension at a time. "
         f"This one touches: {', '.join(sorted(touched_folders))}.")

ext_id = touched_folders.pop()
folder = os.path.join(EXT_DIR, ext_id)

# No deletions of someone else's work — you can only delete files inside your own folder.
if not os.path.isdir(folder):
    fail(f"The folder extensions/{ext_id}/ doesn't exist after this change "
         "(did the pull request delete it?). You can't remove extensions here.")

m, err = read_manifest(folder)
if err:
    fail(f"extensions/{ext_id}: {err}")

blocked_ids, blocked_authors = load_blocklist()
if m["id"] in blocked_ids:
    fail(f"The id \"{m['id']}\" is blocked.")
if str(m["author"]).lower() in blocked_authors:
    fail(f"Submissions from \"{m['author']}\" are blocked.")

# Rate limit: cap how many extensions one author may ADD (anti-spam speed bump).
# Updating your own existing extension is never blocked.
is_new = ext_id in added_manifest
if is_new:
    existing = count_by_author(m["author"], exclude_id=ext_id)
    if existing >= MAX_PER_AUTHOR:
        fail(f"\"{m['author']}\" already has {existing} extensions in the store "
             f"(the limit is {MAX_PER_AUTHOR}). Update an existing one, or ask the maintainer to raise the limit.")

print(f"✅ Looks good: {m['name']} ({m['id']}) v{m['version']} by {m['author']}.")
print("The store will rebuild automatically once this is merged.")
