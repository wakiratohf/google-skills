#!/usr/bin/env bash
# Install Google Android skills to ~/.claude/skills/
# Supports: macOS, Linux
# Usage:
#   ./install.sh          Interactive mode - choose skills to install
#   ./install.sh --all    Install all skills without prompting

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_DIR="${HOME}/.claude/skills"

# Skill registry: ordered arrays for consistent numbering
SKILL_PATHS=(
    "build/agp/agp-9-upgrade"
    "jetpack-compose/migration/migrate-xml-views-to-jetpack-compose"
    "navigation/navigation-3"
    "performance/r8-analyzer"
    "play/play-billing-library-version-upgrade"
    "system/edge-to-edge"
)
SKILL_NAMES=(
    "agp-9-upgrade"
    "migrate-xml-views-to-jetpack-compose"
    "navigation-3"
    "r8-analyzer"
    "play-billing-library-version-upgrade"
    "edge-to-edge"
)
SKILL_DESCS=(
    "Upgrade Android Gradle Plugin to version 9"
    "Migrate XML views to Jetpack Compose"
    "Migrate to Navigation 3"
    "Analyze R8/ProGuard rules for optimization"
    "Upgrade Play Billing Library version"
    "Migrate to edge-to-edge display"
)

TOTAL=${#SKILL_NAMES[@]}

# --- Functions ---

install_skill() {
    local idx=$1
    local src_full="${SCRIPT_DIR}/${SKILL_PATHS[$idx]}"
    local skill_name="${SKILL_NAMES[$idx]}"
    local dest="${SKILLS_DIR}/${skill_name}"

    if [ ! -f "${src_full}/SKILL.md" ]; then
        echo "  [SKIP] ${skill_name} - SKILL.md not found"
        return 1
    fi

    [ -d "${dest}" ] && rm -rf "${dest}"
    cp -r "${src_full}" "${dest}"
    find "${dest}" -name ".DS_Store" -delete 2>/dev/null || true

    echo "  [OK] ${skill_name}"
    return 0
}

show_menu() {
    echo "Google Android Skills Installer"
    echo "================================"
    echo ""
    echo "Available skills:"
    echo ""
    for i in $(seq 0 $((TOTAL - 1))); do
        local status=" "
        local dest="${SKILLS_DIR}/${SKILL_NAMES[$i]}"
        [ -d "${dest}" ] && status="*"
        printf "  [%s] %d) %-40s %s\n" "${status}" $((i + 1)) "${SKILL_NAMES[$i]}" "${SKILL_DESCS[$i]}"
    done
    echo ""
    echo "  [*] = already installed"
    echo ""
    echo "Options:"
    echo "  Enter numbers separated by spaces (e.g. 1 3 5)"
    echo "  a = install all"
    echo "  q = quit"
    echo ""
}

parse_selection() {
    local input="$1"
    local selected=()

    # Handle 'all'
    if [[ "${input}" == "a" || "${input}" == "A" ]]; then
        for i in $(seq 0 $((TOTAL - 1))); do
            selected+=("$i")
        done
        echo "${selected[*]}"
        return 0
    fi

    # Parse space/comma separated numbers and ranges (e.g. "1 3 5" or "1-3,5")
    local tokens
    tokens=$(echo "${input}" | tr ',' ' ')
    for token in ${tokens}; do
        if [[ "${token}" =~ ^([0-9]+)-([0-9]+)$ ]]; then
            local start="${BASH_REMATCH[1]}"
            local end="${BASH_REMATCH[2]}"
            for n in $(seq "${start}" "${end}"); do
                if [ "$n" -ge 1 ] && [ "$n" -le "${TOTAL}" ]; then
                    selected+=($((n - 1)))
                fi
            done
        elif [[ "${token}" =~ ^[0-9]+$ ]]; then
            if [ "${token}" -ge 1 ] && [ "${token}" -le "${TOTAL}" ]; then
                selected+=($((token - 1)))
            else
                echo "INVALID"
                return 1
            fi
        else
            echo "INVALID"
            return 1
        fi
    done

    if [ ${#selected[@]} -eq 0 ]; then
        echo "INVALID"
        return 1
    fi

    # Deduplicate
    echo "${selected[*]}" | tr ' ' '\n' | sort -un | tr '\n' ' '
}

# --- Main ---

mkdir -p "${SKILLS_DIR}"

# --all flag: skip interactive menu
if [ "${1:-}" = "--all" ]; then
    echo "Installing all Google Android skills to ${SKILLS_DIR}..."
    echo ""
    installed=0
    for i in $(seq 0 $((TOTAL - 1))); do
        if install_skill "$i"; then
            installed=$((installed + 1))
        fi
    done
    echo ""
    echo "Done! Installed: ${installed}/${TOTAL}"
    echo "Skills location: ${SKILLS_DIR}"
    exit 0
fi

# Interactive mode
show_menu
printf "Your choice: "
read -r choice

# Quit
if [[ "${choice}" == "q" || "${choice}" == "Q" ]]; then
    echo "Cancelled."
    exit 0
fi

selected_str=$(parse_selection "${choice}") || true
if [ "${selected_str}" = "INVALID" ] || [ -z "${selected_str}" ]; then
    echo "Invalid selection. Please run the script again."
    exit 1
fi

read -ra selected_indices <<< "${selected_str}"

echo ""
echo "Installing ${#selected_indices[@]} skill(s) to ${SKILLS_DIR}..."
echo ""

installed=0
for idx in "${selected_indices[@]}"; do
    if install_skill "$idx"; then
        installed=$((installed + 1))
    fi
done

echo ""
echo "Done! Installed: ${installed}/${#selected_indices[@]}"
echo "Skills location: ${SKILLS_DIR}"
