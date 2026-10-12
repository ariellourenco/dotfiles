#!/usr/bin/env bash
# Validate every skill in .github/skills/ against the agentskills.io specification:
# directory name must equal the frontmatter `name`, description must be 1-1024
# characters, and frontmatter may only use spec keys (name, description, license,
# compatibility, metadata, allowed-tools) plus this repo's own Claude extensions
# (argument-hint, model, color).
#
# The gitignored `synced/` directory holds skills synced from claude.ai and is skipped.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_DIR="$(cd "${SCRIPT_DIR}/../skills" && pwd)"

allowed_keys="name description license compatibility metadata allowed-tools argument-hint model color"

passes=0
failures=0

for skill_dir in "$SKILLS_DIR"/*; do
  [[ -d "$skill_dir" ]] || continue

  skill_name=$(basename "$skill_dir")
  [[ "$skill_name" == "synced" ]] && continue

  skill_file="$skill_dir/SKILL.md"
  problems=""

  if [[ ! -f "$skill_file" ]]; then
    problems+="  missing SKILL.md"$'\n'
  else
    # The frontmatter must open the file and close before the body starts.
    first_line=$(head -n 1 "$skill_file")
    delimiter_count=$(grep -c '^---$' "$skill_file" || true)

    if [[ "$first_line" != "---" ]] || (( delimiter_count < 2 )); then
      problems+="  no frontmatter block"$'\n'
    else
      # Everything between the first two `---` lines.
      frontmatter=$(awk '/^---$/{n++; if (n==2) exit; next} n==1' "$skill_file")

      # Top-level keys only, so indented lines inside a value are ignored.
      fm_keys=$(printf '%s\n' "$frontmatter" | sed -n 's/^\([A-Za-z0-9_-]*\):.*/\1/p')

      fm_name=$(printf '%s\n' "$frontmatter" | sed -n 's/^name:[[:space:]]*//p' | head -1 | tr -d "[:space:]\"'")

      # A description can be folded over several lines (`description: >`), so join its
      # indented continuation lines before measuring, then drop any surrounding quotes.
      fm_desc=$(printf '%s\n' "$frontmatter" | awk '
        /^description:/ { sub(/^description:[ \t]*/, ""); if ($0 ~ /^[>|]/) $0 = ""; desc = $0; in_desc = 1; next }
        in_desc && /^[ \t]/ { sub(/^[ \t]+/, ""); desc = desc (desc == "" ? "" : " ") $0; next }
        { in_desc = 0 }
        END { print desc }' | sed -E "s/^[\"']|[\"']$//g")

      if [[ "$fm_name" != "$skill_name" ]]; then
        problems+="  name '$fm_name' does not match directory '$skill_name'"$'\n'
      fi

      desc_len=${#fm_desc}
      if (( desc_len < 1 || desc_len > 1024 )); then
        problems+="  description length $desc_len outside 1-1024"$'\n'
      fi

      while IFS= read -r key; do
        [[ -n "$key" ]] || continue
        if ! printf '%s\n' $allowed_keys | grep -Fxq "$key"; then
          problems+="  unsupported frontmatter key '$key'"$'\n'
        fi
      done <<< "$fm_keys"
    fi
  fi

  if [[ -n "$problems" ]]; then
    failures=$((failures + 1))
    printf 'FAIL %s\n%s' "$skill_name" "$problems"
  else
    passes=$((passes + 1))
  fi
done

# An empty scan would otherwise read as a clean run.
if (( passes == 0 && failures == 0 )); then
  echo "FAIL no skills found under $SKILLS_DIR"
  exit 1
fi

echo "Validated $((passes + failures)) skills: $passes passed, $failures failed"
(( failures == 0 ))
