#!/usr/bin/env python3
"""Regenerate strudel.json from the audio files in this repo.

Each top-level folder becomes a sound bank named after the folder.
Files within a bank are sorted alphabetically; in Strudel, `s("bank:2")`
picks the third file. Run this after adding/removing samples, then
commit and push.
"""

import json
from pathlib import Path

AUDIO_EXTS = {".wav", ".mp3", ".ogg", ".flac", ".aiff", ".aif", ".m4a"}
ROOT = Path(__file__).resolve().parent

banks = {}
for folder in sorted(ROOT.iterdir()):
    if not folder.is_dir() or folder.name.startswith("."):
        continue
    files = sorted(
        f"{folder.name}/{f.name}"
        for f in folder.rglob("*")
        if f.is_file() and f.suffix.lower() in AUDIO_EXTS
    )
    banks[folder.name] = files

manifest = {"_base": ""}
manifest.update(banks)

out = ROOT / "strudel.json"
out.write_text(json.dumps(manifest, indent=2) + "\n")

total = sum(len(v) for v in banks.values())
print(f"Wrote {out.name}: {len(banks)} bank(s), {total} sample(s)")
for name, files in banks.items():
    print(f"  {name}: {len(files)}")
