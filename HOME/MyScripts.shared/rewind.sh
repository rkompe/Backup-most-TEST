#!/usr/bin/zsh

# Rewind backup snapshot to a previous date.
# Usage: rewind.sh DATE [SUBDIR]
#  DATE   - target date in YYYY-MM-DD format (must match backup names)
#  SUBDIR - optional subdirectory to restore
#
# 250713  Version 0.2 from codex based on my requests

set -euo pipefail

if [[ $# -lt 1 || $# -gt 2 ]]; then
    echo "Usage: $0 DATE [SUBDIR]" >&2
    exit 1
fi

target_date="$1"
subdir="${2:-}"

: "${ziel:?Environment variable 'ziel' must be set to current snapshot root}"
: "${backupdir:?Environment variable 'backupdir' must be set to backup directory}"
: "${backup_prefix:?Environment variable 'backup_prefix' must be set to list prefix}"

# Destination directory for the rewound snapshot.  Include the optional
# subdir name rather than $ziel.
label=${subdir:-all}
label=${label//\//_}
restore_dir="${RESTORE_DIR:-${label}_rewind_${target_date}}"

if [[ -d "$restore_dir" ]]; then
    echo "Destination $restore_dir already exists" >&2
    exit 1
fi

# Find list files in the backup hierarchy
list_root="$backupdir/$subdir"
file_lists=($list_root/${target_date}.*.files.list(N))
dir_lists=($list_root/${target_date}.*.dirs.list(N))

if (( ${#file_lists} == 0 || ${#dir_lists} == 0 )); then
    echo "No lists found for date $target_date under $list_root" >&2
    exit 1
fi

# All backup directories sorted ascending
backup_dirs=($(ls -1d "$backupdir/$subdir"/*/ 2>/dev/null | sort))

# Create directories from all matching lists
cat "${dir_lists[@]}" | while IFS= read -r dir; do
    dir=${dir#$backup_prefix}
    dir=${dir#/}
    [[ -n "$subdir" && "$dir" != ${subdir}* ]] && continue
    dest="$restore_dir/${dir#$subdir/}"
    mkdir -p "$dest"
done

# Helper to restore a single file
restore_file() {
    local rel="$1"
    local trimmed=${rel#$backup_prefix}
    trimmed=${trimmed#/}

    [[ -n "$subdir" && "$trimmed" != ${subdir}* ]] && return

    local relative="$trimmed"
    if [[ -n "$subdir" ]]; then
        relative="${trimmed#$subdir/}"
    fi
    local dest="$restore_dir/$relative"

    local src="$ziel/$trimmed"

    # Walk backup directories oldest to newest starting at target_date
    for b in $backup_dirs; do
        local bdate=$(basename "$b")
        [[ "$bdate" < "$target_date" ]] && continue
        if [[ -f "$b/$trimmed" ]]; then
            src="$b/$trimmed"
            break
        fi
    done

    if [[ -f "$src" ]]; then
        mkdir -p "$(dirname "$dest")"
        cp -p -- "$src" "$dest"
    else
        echo "Warning: $trimmed not found" >&2
    fi
}

# Restore files
cat "${file_lists[@]}" | while IFS= read -r file; do
    restore_file "$file"
done

echo "Restored snapshot to $restore_dir"

