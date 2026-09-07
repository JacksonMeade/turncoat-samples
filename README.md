# turncoat-samples

Audio samples for use in [Strudel](https://strudel.cc).

## Use in Strudel

```js
samples('github:JacksonMeade/turncoat-samples')

s("misc:0") // play the first sample in the "misc" bank
```

Each top-level folder in this repo is a sound bank; `bank:n` selects the
n-th file (alphabetical, zero-indexed) in that folder.

## Adding samples

1. Drop audio files (`.wav`, `.mp3`, `.ogg`, `.flac`, `.aiff`, `.m4a`) into a
   top-level folder — the folder name becomes the bank name. Create new
   folders freely.
2. Regenerate the manifest:

   ```sh
   python3 update-manifest.py
   ```

3. Commit and push. Strudel fetches `strudel.json` from the `main` branch
   via raw.githubusercontent.com, so changes go live on push (raw URLs can
   be cached for a few minutes).

## Notes

- The repo must stay **public** — Strudel loads files over raw GitHub URLs.
- Don't use Git LFS: raw.githubusercontent.com serves LFS pointer files,
  not audio, which breaks Strudel. Keep files under GitHub's 100 MB
  per-file limit (samples should be far smaller anyway).
- Prefer short, trimmed samples; Strudel downloads each file on first use.
