#!/bin/bash
# Validate YAML frontmatter in Claude Code plugin marketplace markdown files.
# Pure shell implementation - no Python dependencies.

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

error() { echo -e "${RED}ERROR${NC} $1: $2" >&2; }
success() { echo -e "${GREEN}OK${NC} $1: Frontmatter valid"; }

# Check if file has frontmatter (starts with ---)
has_frontmatter() {
    local file="$1"
    head -1 "$file" | grep -q '^---$'
}

# Extract frontmatter content between --- markers
get_frontmatter() {
    local file="$1"
    awk '/^---$/{if(++c==1)next; if(c==2)exit} c==1{print}' "$file"
}

# Check if a field exists in frontmatter
has_field() {
    local frontmatter="$1"
    local field="$2"
    echo "$frontmatter" | grep -qE "^${field}:"
}

# Get file type based on path
get_file_type() {
    local file="$1"

    # Check for skill files (*/skills/*/SKILL.md or skills/*/SKILL.md)
    if [[ "$file" == *"/skills/"*"/SKILL.md" ]] || [[ "$file" == "skills/"*"/SKILL.md" ]]; then
        echo "skill"
        return
    fi

    # Check for agent files (*/agents/*.md or agents/*.md)
    if [[ "$file" == *"/agents/"*.md ]] || [[ "$file" == "agents/"*.md ]]; then
        echo "agent"
        return
    fi

    # Check for command files (*/commands/*.md or commands/*.md)
    if [[ "$file" == *"/commands/"*.md ]] || [[ "$file" == "commands/"*.md ]]; then
        echo "command"
        return
    fi

    # Skip template files
    if [[ "$file" == *"/template/"* ]] || [[ "$file" == "template/"* ]]; then
        echo "skip"
        return
    fi

    # Skip language config files
    if [[ "$file" == *"/languages/"* ]]; then
        echo "skip"
        return
    fi

    echo "unknown"
}

validate_file() {
    local file="$1"
    local errors=0

    # Skip non-markdown files
    [[ "$file" != *.md ]] && return 0

    # Get file type
    local file_type
    file_type=$(get_file_type "$file")

    # Skip unknown or template files
    [[ "$file_type" == "unknown" || "$file_type" == "skip" ]] && return 0

    # Check frontmatter exists
    if ! has_frontmatter "$file"; then
        error "$file" "No frontmatter found (must start with ---)"
        return 1
    fi

    # Extract frontmatter
    local frontmatter
    frontmatter=$(get_frontmatter "$file")

    if [[ -z "$frontmatter" ]]; then
        error "$file" "Empty frontmatter"
        return 1
    fi

    # Validate required fields based on file type
    case "$file_type" in
        skill|agent|command)
            if ! has_field "$frontmatter" "name"; then
                error "$file" "Missing required field 'name'"
                errors=$((errors + 1))
            fi
            if ! has_field "$frontmatter" "description"; then
                error "$file" "Missing required field 'description'"
                errors=$((errors + 1))
            fi
            ;;
    esac

    if [[ $errors -gt 0 ]]; then
        return 1
    fi

    success "$file"
    return 0
}

main() {
    local exit_code=0
    local files=()

    if [[ $# -eq 0 ]]; then
        # Find all markdown files in claude-code/ and skills/ directories
        while IFS= read -r -d '' file; do
            files+=("$file")
        done < <(find claude-code/agents claude-code/commands claude-code/skills skills -name "*.md" -print0 2>/dev/null)

        if [[ ${#files[@]} -eq 0 ]]; then
            echo "No markdown files found to validate"
            exit 0
        fi
    else
        files=("$@")
    fi

    for file in "${files[@]}"; do
        if [[ ! -f "$file" ]]; then
            echo "  $file: File not found, skipping"
            continue
        fi

        if ! validate_file "$file"; then
            exit_code=1
        fi
    done

    return $exit_code
}

main "$@"
