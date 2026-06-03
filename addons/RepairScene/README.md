# RepairScene — Lite

> **Stop fighting your engine. Ship faster.**

---

## The Problem

You renamed a folder. Now half your scenes show "Scene file appears to be invalid/corrupt" and Godot refuses to open them. The `.tscn` files contain hard-coded resource paths that no longer exist. Fixing them manually means opening each file in a text editor and rewriting every broken `ext_resource` path by hand.

---

## The Solution

`script.gd` is an EditorScript that scans your `.tscn` files as raw text (bypassing Godot's resource loader entirely — the whole point is to fix files Godot can't open), finds every broken `path=` reference, and resolves it by matching the filename stem against your current project filesystem. Run it once. Your scenes open again.

Always run in dry-run mode first (`write_changes = false`) to review what it would change before touching any file.

---

## What's in the Lite Version

- Scans your entire project (or a subfolder) for broken `.tscn` references
- Resolves broken paths by **exact filename stem match** — handles the most common case: file moved to a different folder with the same name
- Strips stale `uid=` tokens so Godot regenerates them cleanly on next import
- Backup system: creates `.bak` files before overwriting anything
- Dry-run mode: logs all changes without writing to disk
- Summary table: files scanned, refs broken, refs resolved, refs unresolved

## What's in the Full Version

The full version adds **fuzzy path resolution**: when a file has been both renamed *and* moved, the exact stem match will fail. The full version uses a segment-ratio scoring algorithm that compares path segments right-to-left, scoring each candidate in your filesystem and accepting the best match above a configurable threshold. It also adds `prefer_closest_directory` to automatically disambiguate multiple files with the same name by picking the one in the closest matching folder. These two features handle the hard cases the lite version cannot.

**Full version on itch.io:** https://nullstateassets.itch.io

---

## Quick Start

1. Copy `script.gd` into your Godot project.
2. In Godot: File > New Script, set base class to `EditorScript`, paste the script contents.
3. Configure `scan_root` and ensure `write_changes` is `false` for the first run.
4. File > Run (or Ctrl+Shift+X) to execute.
5. Review the Output panel. Set `write_changes = true` to apply.

---

## Compatibility

| Engine    | Language  | Tested On    |
|-----------|-----------|--------------|
| Godot 4.x | GDScript  | 4.2, 4.3     |

---

## License

MIT License. Free for personal and commercial use. Attribution appreciated but not required.
