class_name RepairScene
extends EditorScript

# LITE VERSION — Full version adds fuzzy path resolution: when a file has been
# both renamed AND moved to a different folder, the full version uses a
# segment-ratio scoring algorithm to find the best candidate across your entire
# project. Lite resolves only by exact filename stem (same name, any location).
# It also adds prefer_closest_directory to disambiguate multiple same-name files
# by picking the one whose folder path most closely matches the original.
# Full version: https://nullstateassets.itch.io

# ============================================================
# RepairScene — Godot 4.x Scene GUID / UID Repair Tool
#
# HOW TO USE:
#   1. Attach this script to an EditorScript node (File > New Script,
#      set base class to EditorScript, or use Script > Run).
#   2. Configure the exported variables below in the Inspector.
#   3. Click File > Run (Ctrl+Shift+X) to execute the repair pass.
#
# WHAT IT DOES:
#   Scans .tscn files for ext_resource references whose paths no longer
#   exist on disk, then attempts to resolve them by matching filename
#   stems against the current FileSystem. Broken uid="uid://..." tokens
#   are also stripped so Godot stops complaining about corrupt headers.
# ============================================================

@export_category("Target")
@export_group("Scan Scope")

## Root directory to scan. "res://" scans the entire project.
## Narrow this to a subfolder (e.g. "res://scenes/") to limit scope.
@export var scan_root: String = "res://"

## When true, the tool descends into every subdirectory recursively.
## Set false to repair only the immediate files inside scan_root.
@export var recursive_scan: bool = true

## File extensions to treat as repairable scene files.
## .tscn is the human-readable format; .scn (binary) is intentionally
## excluded because binary patching without the full resource format
## spec would corrupt data silently.
@export var target_extensions: PackedStringArray = ["tscn"]

@export_group("Safety")

## Writes repaired content back to disk. When false the tool runs in
## dry-run mode: it logs every change it would make without touching
## any file. Always do a dry run first on an unfamiliar project.
@export var write_changes: bool = false

## Creates a timestamped .bak copy of each file before overwriting.
## Strongly recommended when write_changes is true.
@export var create_backups: bool = true

## Backup files are placed here. Leave blank to write the .bak file
## beside the original (safest — keeps backup next to source).
@export var backup_directory: String = ""

## If a .bak file already exists for a given scene, skip writing a
## second backup. Prevents backup sprawl on repeated repair runs.
@export var skip_existing_backups: bool = true

@export_group("Logging")

## Prints a line for every ext_resource and sub_resource entry
## inspected, not just the broken ones. Useful for auditing but
## very verbose on large projects.
@export var verbose_logging: bool = false

## Prints a final summary table of files scanned, broken refs found,
## refs resolved, and refs that could not be resolved.
@export var print_summary: bool = true

# ─────────────────────────────────────────────────────────────
# Internal state — not exported; reset on every _run() call.
# ─────────────────────────────────────────────────────────────
var _filesystem_map: Dictionary = {}   # stem (lower) → [Array of absolute res:// paths]
var _stats: Dictionary = {
	"files_scanned": 0,
	"files_modified": 0,
	"refs_inspected": 0,
	"refs_broken": 0,
	"refs_resolved": 0,
	"refs_unresolved": 0,
	"backups_written": 0,
}


# ─────────────────────────────────────────────────────────────
# Entry point called by Godot when the EditorScript is executed.
# ─────────────────────────────────────────────────────────────
func _run() -> void:
	_reset_stats()
	_filesystem_map.clear()

	print("[RepairScene] ── Scan started ──────────────────────────")
	print("[RepairScene] Scan root      : ", scan_root)
	print("[RepairScene] Recursive      : ", recursive_scan)
	print("[RepairScene] Write changes  : ", write_changes)
	print("[RepairScene] Create backups : ", create_backups)
	print("────────────────────────────────────────────────────────")

	# Build the filesystem map before touching any scene file so that
	# resolution queries during the repair pass are O(1) stem lookups
	# rather than repeated directory walks.
	_build_filesystem_map(scan_root)

	var scene_files: Array[String] = []
	_collect_scene_files(scan_root, scene_files)

	for path in scene_files:
		_process_scene_file(path)

	if print_summary:
		_print_summary()

	print("[RepairScene] ── Scan complete ─────────────────────────")


# ─────────────────────────────────────────────────────────────
# Recursively walks the project filesystem and indexes every file
# by its lowercase stem so resolution is a dictionary lookup.
# We index ALL files (not just target extensions) because a broken
# .tscn might reference a .png, .tres, .gd, or any other asset.
# ─────────────────────────────────────────────────────────────
func _build_filesystem_map(directory: String) -> void:
	var dir := DirAccess.open(directory)
	if dir == null:
		push_warning("[RepairScene] Cannot open directory for indexing: " + directory)
		return

	dir.list_dir_begin()
	var entry := dir.get_next()
	while entry != "":
		if entry == "." or entry == "..":
			entry = dir.get_next()
			continue

		var full_path := directory.path_join(entry)

		if dir.current_is_dir():
			# .godot is the engine's internal cache; indexing it would
			# pollute the map with generated UIDs and import artifacts.
			if entry != ".godot" and recursive_scan:
				_build_filesystem_map(full_path)
		else:
			var stem := entry.get_basename().to_lower()
			if not _filesystem_map.has(stem):
				_filesystem_map[stem] = []
			(_filesystem_map[stem] as Array).append(full_path)

		entry = dir.get_next()

	dir.list_dir_end()


# ─────────────────────────────────────────────────────────────
# Collects all scene files matching target_extensions under root.
# ─────────────────────────────────────────────────────────────
func _collect_scene_files(directory: String, result: Array[String]) -> void:
	var dir := DirAccess.open(directory)
	if dir == null:
		return

	dir.list_dir_begin()
	var entry := dir.get_next()
	while entry != "":
		if entry == "." or entry == "..":
			entry = dir.get_next()
			continue

		var full_path := directory.path_join(entry)

		if dir.current_is_dir():
			if entry != ".godot" and recursive_scan:
				_collect_scene_files(full_path, result)
		else:
			var ext := entry.get_extension().to_lower()
			if ext in target_extensions:
				result.append(full_path)

		entry = dir.get_next()

	dir.list_dir_end()


# ─────────────────────────────────────────────────────────────
# Core repair logic for a single .tscn file.
# Reads the file line-by-line rather than loading it through
# ResourceLoader because a corrupt scene may fail to load at all —
# the entire point of this tool is to fix files Godot refuses to open.
# ─────────────────────────────────────────────────────────────
func _process_scene_file(scene_path: String) -> void:
	_stats["files_scanned"] += 1

	var file := FileAccess.open(scene_path, FileAccess.READ)
	if file == null:
		push_warning("[RepairScene] Cannot read: " + scene_path)
		return

	var original_lines: PackedStringArray = []
	while not file.eof_reached():
		original_lines.append(file.get_line())
	file.close()

	var repaired_lines: PackedStringArray = original_lines.duplicate()
	var file_was_modified := false

	for i in range(repaired_lines.size()):
		var line: String = repaired_lines[i]

		# Only ext_resource headers carry the path= attribute that
		# references external files. sub_resource headers reference
		# internal IDs and don't need path resolution.
		if not line.begins_with("[ext_resource"):
			if verbose_logging and (line.begins_with("[sub_resource") or line.begins_with("[resource")):
				print("[RepairScene]   sub_resource line (no path repair needed): ", line.left(80))
			continue

		_stats["refs_inspected"] += 1

		var path_value := _extract_attribute(line, "path")
		if path_value.is_empty():
			if verbose_logging:
				print("[RepairScene]   No path= attribute found on line ", i, ": ", line.left(80))
			continue

		if verbose_logging:
			print("[RepairScene]   Inspecting ref: ", path_value)

		# FileAccess.file_exists resolves res:// paths through the
		# project's resource system, so this correctly handles both
		# absolute and relative resource paths.
		if FileAccess.file_exists(path_value):
			if verbose_logging:
				print("[RepairScene]   ✓ Path valid: ", path_value)
			continue

		# ── Path is broken ──────────────────────────────────────
		_stats["refs_broken"] += 1
		print("[RepairScene] ✗ Broken ref in [", scene_path.get_file(), "]: ", path_value)

		var resolved := _resolve_path(path_value)

		if resolved.is_empty():
			_stats["refs_unresolved"] += 1
			push_warning("[RepairScene]   Could not resolve: " + path_value)
			continue

		_stats["refs_resolved"] += 1
		print("[RepairScene]   → Resolved to: ", resolved)

		# Replace only the path= value, preserving every other attribute
		# (type=, id=, uid=) on the line so we don't corrupt the header.
		var new_line := _replace_attribute(line, "path", resolved)

		# Regenerate uid= when present because the old UID was tied to
		# the original file path; after remapping the path the UID is
		# stale and will cause "uid mismatch" warnings on next import.
		if "uid=" in new_line:
			new_line = _strip_uid(new_line)

		repaired_lines[i] = new_line
		file_was_modified = true

	if not file_was_modified:
		return

	_stats["files_modified"] += 1

	if not write_changes:
		print("[RepairScene] [DRY RUN] Would modify: ", scene_path)
		return

	if create_backups:
		_write_backup(scene_path, original_lines)

	var out := FileAccess.open(scene_path, FileAccess.WRITE)
	if out == null:
		push_error("[RepairScene] Cannot write repaired file: " + scene_path)
		return

	# Join with \n and append a trailing newline to match Godot's own
	# scene serializer output, preventing spurious diffs in version control.
	out.store_string("\n".join(repaired_lines) + "\n")
	out.close()
	print("[RepairScene] ✔ Written: ", scene_path)


# ─────────────────────────────────────────────────────────────
# Attempts to find a valid res:// path for a broken reference
# using exact filename stem matching only. Resolves the most
# common breakage case: file moved to a different folder with
# the same name. Does NOT handle renamed files — upgrade to
# the full version for fuzzy segment-ratio matching.
# ─────────────────────────────────────────────────────────────
func _resolve_path(broken_path: String) -> String:
	var broken_file: String = broken_path.get_file()          # e.g. "Player.png"
	var broken_stem: String = broken_file.get_basename().to_lower()
	var broken_ext: String  = broken_file.get_extension().to_lower()

	if not _filesystem_map.has(broken_stem):
		return ""

	var candidates: Array = _filesystem_map[broken_stem]

	# Filter by extension so "Player.png" doesn't resolve to "Player.gd".
	# Extension mismatch would silently corrupt the resource type.
	var ext_filtered: Array = candidates.filter(
		func(c: String) -> bool:
			return c.get_extension().to_lower() == broken_ext
	)

	if ext_filtered.is_empty():
		return ""

	if ext_filtered.size() > 1:
		# Multiple candidates with same stem and extension — log and pick first.
		# The full version uses directory proximity scoring to disambiguate.
		push_warning("[RepairScene]   Ambiguous stem '" + broken_stem + "' — picking first of " + str(ext_filtered.size()) + " candidates. Full version resolves ambiguity automatically.")

	return ext_filtered[0]


# ─────────────────────────────────────────────────────────────
# Resets all counters in _stats to zero before a new repair run.
# ─────────────────────────────────────────────────────────────
func _reset_stats() -> void:
	_stats = {
		"files_scanned": 0,
		"files_modified": 0,
		"refs_inspected": 0,
		"refs_broken": 0,
		"refs_resolved": 0,
		"refs_unresolved": 0,
		"backups_written": 0,
	}


# ─────────────────────────────────────────────────────────────
# Prints a formatted summary table to the Godot output panel.
# ─────────────────────────────────────────────────────────────
func _print_summary() -> void:
	print("────────────────────────────────────────────────────────")
	print("[RepairScene] ── Summary ───────────────────────────────")
	print("[RepairScene] Files scanned    : ", _stats["files_scanned"])
	print("[RepairScene] Files modified   : ", _stats["files_modified"])
	print("[RepairScene] Refs inspected   : ", _stats["refs_inspected"])
	print("[RepairScene] Refs broken      : ", _stats["refs_broken"])
	print("[RepairScene] Refs resolved    : ", _stats["refs_resolved"])
	print("[RepairScene] Refs unresolved  : ", _stats["refs_unresolved"])
	print("[RepairScene] Backups written  : ", _stats["backups_written"])
	print("────────────────────────────────────────────────────────")


# ─────────────────────────────────────────────────────────────
# Extracts the value of a quoted attribute from a .tscn header line.
# e.g. _extract_attribute('[ext_resource path="res://foo.png" ...]', "path")
# returns "res://foo.png".  Returns "" when the attribute is absent.
# ─────────────────────────────────────────────────────────────
func _extract_attribute(line: String, attr: String) -> String:
	var search := attr + '="'
	var start := line.find(search)
	if start == -1:
		return ""
	start += search.length()
	var end := line.find('"', start)
	if end == -1:
		return ""
	return line.substr(start, end - start)


# ─────────────────────────────────────────────────────────────
# Returns a copy of line with the value of the named attribute
# replaced by new_value.  All other attributes are preserved verbatim.
# ─────────────────────────────────────────────────────────────
func _replace_attribute(line: String, attr: String, new_value: String) -> String:
	var search := attr + '="'
	var start := line.find(search)
	if start == -1:
		return line
	var value_start := start + search.length()
	var value_end := line.find('"', value_start)
	if value_end == -1:
		return line
	return line.substr(0, value_start) + new_value + line.substr(value_end)


# ─────────────────────────────────────────────────────────────
# Removes the uid="uid://..." token from a .tscn header line.
# The UID becomes stale after a path remap; Godot will assign a
# fresh UID on the next project scan.
# ─────────────────────────────────────────────────────────────
func _strip_uid(line: String) -> String:
	var regex := RegEx.new()
	regex.compile('\\s*uid="[^"]*"')
	return regex.sub(line, "")


# ─────────────────────────────────────────────────────────────
# Writes a .bak copy of scene_path before it is overwritten.
# Respects backup_directory and skip_existing_backups settings.
# ─────────────────────────────────────────────────────────────
func _write_backup(scene_path: String, lines: PackedStringArray) -> void:
	var bak_path: String
	if backup_directory.is_empty():
		bak_path = scene_path + ".bak"
	else:
		bak_path = backup_directory.path_join(scene_path.get_file() + ".bak")

	if skip_existing_backups and FileAccess.file_exists(bak_path):
		if verbose_logging:
			print("[RepairScene]   Backup already exists, skipping: ", bak_path)
		return

	var out := FileAccess.open(bak_path, FileAccess.WRITE)
	if out == null:
		push_warning("[RepairScene] Cannot write backup: " + bak_path)
		return

	out.store_string("\n".join(lines) + "\n")
	out.close()
	_stats["backups_written"] += 1
	print("[RepairScene]   Backup written: ", bak_path)
