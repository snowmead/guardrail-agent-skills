#!/bin/bash
# Validate Claude Code plugin marketplace structure
set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

error() { echo -e "${RED}ERROR: $1${NC}" >&2; }
warn() { echo -e "${YELLOW}WARNING: $1${NC}" >&2; }
success() { echo -e "${GREEN}$1${NC}"; }

cd "$(dirname "$0")/.."

validate_marketplace_json() {
    echo "Validating marketplace.json..."

    if [[ ! -f ".claude-plugin/marketplace.json" ]]; then
        error "Missing .claude-plugin/marketplace.json"
        exit 1
    fi

    if ! uv run python -c "import json; json.load(open('.claude-plugin/marketplace.json'))" 2>/dev/null; then
        error "Invalid JSON syntax in marketplace.json"
        exit 1
    fi

    local required_fields=("name" "owner" "plugins")
    for field in "${required_fields[@]}"; do
        if ! uv run python -c "import json; d=json.load(open('.claude-plugin/marketplace.json')); assert '$field' in d" 2>/dev/null; then
            error "Missing required field '$field' in marketplace.json"
            exit 1
        fi
    done

    if ! uv run python -c "import json; d=json.load(open('.claude-plugin/marketplace.json')); assert 'name' in d['owner']" 2>/dev/null; then
        error "Missing 'name' in marketplace.json owner field"
        exit 1
    fi

    if uv run python -c "import json; d=json.load(open('.claude-plugin/marketplace.json')); assert 'metadata' in d and 'version' in d['metadata']" 2>/dev/null; then
        local version
        version=$(uv run python -c "import json; print(json.load(open('.claude-plugin/marketplace.json'))['metadata']['version'])")
        if ! [[ $version =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
            error "Invalid version format '$version'. Use semantic versioning (x.y.z)"
            exit 1
        fi
    fi

    if ! uv run python -c "
import json
d = json.load(open('.claude-plugin/marketplace.json'))
plugins = d.get('plugins', [])
assert len(plugins) > 0, 'plugins array is empty'
for p in plugins:
    assert 'name' in p and p['name'], 'plugin missing name'
    assert 'source' in p and p['source'], 'plugin missing source'
" 2>/dev/null; then
        error "Each plugin in marketplace.json must have 'name' and 'source'"
        exit 1
    fi

    success "  marketplace.json is valid"
}

validate_plugin_json() {
    echo "Validating plugin source directories..."

    while IFS= read -r plugin_source; do
        plugin_source="${plugin_source#./}"

        if [[ ! -d "$plugin_source" ]]; then
            error "Plugin source directory '$plugin_source' does not exist"
            exit 1
        fi

        local plugin_json="$plugin_source/.claude-plugin/plugin.json"
        if [[ ! -f "$plugin_json" ]]; then
            error "Plugin '$plugin_source' is missing .claude-plugin/plugin.json"
            exit 1
        fi

        if ! uv run python -c "import json; json.load(open('$plugin_json'))" 2>/dev/null; then
            error "Invalid JSON syntax in $plugin_json"
            exit 1
        fi

        # Validate required fields in plugin.json
        if ! uv run python -c "
import json
d = json.load(open('$plugin_json'))
assert 'name' in d and d['name'], 'plugin.json missing name'
assert 'version' in d and d['version'], 'plugin.json missing version'
assert 'description' in d and d['description'], 'plugin.json missing description'
" 2>/dev/null; then
            error "Plugin '$plugin_json' must have 'name', 'version', and 'description'"
            exit 1
        fi

        echo "  Found plugin: $plugin_source"
        success "    plugin.json is valid"
    done < <(uv run python -c "
import json
d = json.load(open('.claude-plugin/marketplace.json'))
for plugin in d.get('plugins', []):
    print(plugin.get('source', ''))
")
}

validate_skill_directories() {
    echo "Validating skill directories..."

    local skill_count=0

    # Check for skills in claude-code/skills/
    if [[ -d "claude-code/skills" ]]; then
        while IFS= read -r -d '' skill_dir; do
            local skill_name
            skill_name=$(basename "$skill_dir")

            if [[ ! -f "$skill_dir/SKILL.md" ]]; then
                error "Skill directory '$skill_dir' is missing SKILL.md"
                exit 1
            fi

            if [[ ! -f "$skill_dir/LICENSE.txt" ]]; then
                warn "Skill directory '$skill_dir' is missing LICENSE.txt (recommended)"
            fi

            skill_count=$((skill_count + 1))
            echo "  Found skill: $skill_dir"
        done < <(find "claude-code/skills" -mindepth 1 -maxdepth 1 -type d -print0)
    fi

    # Also check for dual discovery path skills in root skills/
    if [[ -d "skills" ]]; then
        while IFS= read -r -d '' skill_dir; do
            local skill_name
            skill_name=$(basename "$skill_dir")

            # Skip old guardrail-commit-hooks directory if it exists
            if [[ "$skill_name" == "guardrail-commit-hooks" ]]; then
                continue
            fi

            if [[ -f "$skill_dir/SKILL.md" ]]; then
                echo "  Found dual discovery skill: $skill_dir"
            fi
        done < <(find "skills" -mindepth 1 -maxdepth 1 -type d -print0)
    fi

    if [[ $skill_count -eq 0 ]]; then
        error "No skills found in claude-code/skills/"
        exit 1
    fi

    success "  Found $skill_count skill(s)"
}

validate_commands() {
    echo "Validating command files..."

    local cmd_count=0

    if [[ -d "claude-code/commands" ]]; then
        while IFS= read -r -d '' cmd_file; do
            local cmd_name
            cmd_name=$(basename "$cmd_file" .md)
            cmd_count=$((cmd_count + 1))
            echo "  Found command: $cmd_name"
        done < <(find "claude-code/commands" -name "*.md" -print0)
    fi

    if [[ $cmd_count -eq 0 ]]; then
        warn "No commands found in claude-code/commands/ (optional)"
    else
        success "  Found $cmd_count command(s)"
    fi
}

validate_agents() {
    echo "Validating agents..."

    local agent_count=0

    if [[ -d "claude-code/agents" ]]; then
        while IFS= read -r -d '' agent_file; do
            local agent_name
            agent_name=$(basename "$agent_file" .md)
            agent_count=$((agent_count + 1))
            echo "  Found agent: $agent_name"
        done < <(find "claude-code/agents" -name "*.md" -print0)
    fi

    if [[ $agent_count -eq 0 ]]; then
        echo "  No agents found in claude-code/agents/ (optional)"
    else
        success "  Found $agent_count agent(s)"
    fi
}

validate_yaml_json_syntax() {
    echo "Validating YAML/JSON file syntax..."

    local errors=0

    while IFS= read -r -d '' file; do
        if ! uv run --with pyyaml python -c "import yaml; yaml.safe_load(open('$file'))" 2>/dev/null; then
            error "Invalid YAML syntax in '$file'"
            errors=$((errors + 1))
        fi
    done < <(find . -type f \( -name "*.yml" -o -name "*.yaml" \) -not -path "./.git/*" -print0)

    while IFS= read -r -d '' file; do
        if ! uv run python -c "import json; json.load(open('$file'))" 2>/dev/null; then
            error "Invalid JSON syntax in '$file'"
            errors=$((errors + 1))
        fi
    done < <(find . -type f -name "*.json" -not -path "./.git/*" -not -path "./node_modules/*" -print0)

    if [[ $errors -gt 0 ]]; then
        exit 1
    fi

    success "  All YAML/JSON files have valid syntax"
}

main() {
    echo ""
    echo "Validating Claude Code plugin marketplace structure..."
    echo ""

    validate_marketplace_json
    validate_plugin_json
    validate_skill_directories
    validate_commands
    validate_agents
    validate_yaml_json_syntax

    echo ""
    success "Plugin marketplace validation passed!"
    echo ""
}

main "$@"
