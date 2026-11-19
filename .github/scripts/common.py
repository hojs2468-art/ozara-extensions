"""Shared helpers for the Ozara extension-store bots."""
import json, os, re, sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
EXT_DIR = os.path.join(ROOT, "extensions")
DIST_DIR = os.path.join(ROOT, "dist")

# The repo the app downloads from. The build bot writes raw URLs using this.
EXTENSIONS_REPO = os.environ.get("EXTENSIONS_REPO", "hojs2468-art/ozara-extensions")
RAW_BASE = f"https://raw.githubusercontent.com/{EXTENSIONS_REPO}/main/dist"

# Most extensions one author may have in the store (a spam speed bump; raise or
# lower freely). The author name comes from the manifest, so this is a soft
# limit — for real abuse use GitHub's Interaction Limits and Block user.
MAX_PER_AUTHOR = int(os.environ.get("MAX_PER_AUTHOR", "8"))

ID_RE = re.compile(r"^[a-z0-9]+(\.[a-z0-9]+)+$")
ALLOWED_FILE_EXT = {".luau", ".json", ".md", ".txt", ".png", ".jpg", ".jpeg", ".wav"}
REQUIRED_FIELDS = ["id", "name", "version", "author", "description", "main", "permissions"]

def load_blocklist():
    """Banned extension ids and author names (one per line, '#' comments)."""
    ids, authors = set(), set()
    path = os.path.join(ROOT, "blocklist.txt")
    if not os.path.exists(path):
        return ids, authors
    for line in open(path, encoding="utf-8"):
        line = line.split("#", 1)[0].strip()
        if not line:
            continue
        if line.lower().startswith("author:"):
            authors.add(line.split(":", 1)[1].strip().lower())
        else:
            ids.add(line.strip())
    return ids, authors

def read_manifest(folder):
    """Reads and checks one extension folder's manifest.json. Returns (manifest, error)."""
    mpath = os.path.join(folder, "manifest.json")
    if not os.path.exists(mpath):
        return None, "no manifest.json"
    try:
        m = json.load(open(mpath, encoding="utf-8"))
    except Exception as e:
        return None, f"manifest.json isn't valid JSON: {e}"
    for field in REQUIRED_FIELDS:
        if field not in m:
            return None, f"manifest.json is missing \"{field}\""
    if not ID_RE.match(str(m["id"])):
        return None, f"id \"{m['id']}\" must be lowercase like \"yourname.extension\""
    if os.path.basename(folder) != m["id"]:
        return None, f"the folder must be named exactly \"{m['id']}\" (it's \"{os.path.basename(folder)}\")"
    if not isinstance(m["permissions"], list):
        return None, "permissions must be a list"
    main_path = os.path.join(folder, m["main"])
    if not os.path.isfile(main_path):
        return None, f"the main script \"{m['main']}\" is missing"
    return m, None


def count_by_author(author, exclude_id=None):
    """How many extensions already in the store list this author (case-insensitive)."""
    author = str(author).strip().lower()
    n = 0
    if not os.path.isdir(EXT_DIR):
        return 0
    for name in os.listdir(EXT_DIR):
        folder = os.path.join(EXT_DIR, name)
        if not os.path.isdir(folder) or name == exclude_id:
            continue
        m, err = read_manifest(folder)
        if err:
            continue
        if str(m.get("author", "")).strip().lower() == author:
            n += 1
    return n
