#!/bin/zsh

# Rewind backup snapshot to a previous date.
# Usage: rewind.sh DATE [SUBDIR]
#  DATE   - target date in YYYY-MM-DD format (must match backup names)
#  SUBDIR - optional subdirectory to restore

set -euo pipefail

if [[ $# -lt 1 || $# -gt 2 ]]; then
    echo "Usage: $0 DATE [SUBDIR]" >&2
    exit 1
fi

target_date="$1"
subdir="${2:-}"

: "${ziel:?Environment variable 'ziel' must be set to current snapshot root}"
: "${backupdir:?Environment variable 'backupdir' must be set to backup directory
}"

# Destination directory for the rewound snapshot
restore_dir="${RESTORE_DIR:-${ziel}_rewind_${target_date}}"

if [[ -d "$restore_dir" ]]; then
    echo "Destination $restore_dir already exists" >&2
    exit 1
fi

# Find list files
file_list=$(ls "$backupdir"/files_*"$target_date"* 2>/dev/null | sort | tail -n1
)
dir_list=$(ls "$backupdir"/dirs_*"$target_date"* 2>/dev/null | sort | tail -n1)

if [[ ! -f "$file_list" || ! -f "$dir_list" ]]; then
    echo "No lists found for date $target_date" >&2
    exit 1
fi

# Create directories
while IFS= read -r dir; do
    [[ -n "$subdir" && "$dir" != ${subdir}* ]] && continue
    mkdir -p "$restore_dir/$dir"
done < "$dir_list"

# Helper to restore a single file
restore_file() {
    local rel="$1"
    local dest="$restore_dir/$rel"
    local src="$ziel/$rel"

    # Walk backup directories newest to oldest, stopping at target_date
    for b in $(ls -d "$backupdir"/*(/) 2>/dev/null | sort -r); do
        local bdate=$(basename "$b")
        [[ "$bdate" > "$target_date" ]] || break
        if [[ -f "$b/$rel" ]]; then
            src="$b/$rel"
            break
        fi
    done

    if [[ -f "$src" ]]; then
        cp -p -- "$src" "$dest"
    fi
}

# Restore files
while IFS= read -r file; do
    [[ -n "$subdir" && "$file" != ${subdir}* ]] && continue
    restore_file "$file"
done < "$file_list"

echo "Restored snapshot to $restore_dir"
