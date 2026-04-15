# Install Google Android skills to ~/.claude/skills/
# Supports: Windows (PowerShell), Linux (pwsh), macOS (pwsh)
# Usage:
#   ./install.ps1          Interactive mode - choose skills to install
#   ./install.ps1 -All     Install all skills without prompting

param(
    [switch]$All
)

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$SkillsDir = Join-Path $HOME ".claude" "skills"

# Skill registry - ordered list for consistent numbering
$Skills = @(
    @{ Path = "build/agp/agp-9-upgrade";                                         Name = "agp-9-upgrade";                         Desc = "Upgrade Android Gradle Plugin to version 9" }
    @{ Path = "jetpack-compose/migration/migrate-xml-views-to-jetpack-compose";   Name = "migrate-xml-views-to-jetpack-compose";  Desc = "Migrate XML views to Jetpack Compose" }
    @{ Path = "navigation/navigation-3";                                          Name = "navigation-3";                          Desc = "Migrate to Navigation 3" }
    @{ Path = "performance/r8-analyzer";                                          Name = "r8-analyzer";                           Desc = "Analyze R8/ProGuard rules for optimization" }
    @{ Path = "play/play-billing-library-version-upgrade";                        Name = "play-billing-library-version-upgrade";  Desc = "Upgrade Play Billing Library version" }
    @{ Path = "system/edge-to-edge";                                              Name = "edge-to-edge";                          Desc = "Migrate to edge-to-edge display" }
)

# --- Functions ---

function Install-Skill {
    param([int]$Index)

    $skill = $Skills[$Index]
    $srcPath = Join-Path $ScriptDir ($skill.Path -replace "/", [IO.Path]::DirectorySeparatorChar)
    $dest = Join-Path $SkillsDir $skill.Name
    $skillFile = Join-Path $srcPath "SKILL.md"

    if (-not (Test-Path $skillFile)) {
        Write-Host "  [SKIP] $($skill.Name) - SKILL.md not found"
        return $false
    }

    if (Test-Path $dest) {
        Remove-Item -Recurse -Force $dest
    }

    Copy-Item -Recurse -Path $srcPath -Destination $dest

    Get-ChildItem -Path $dest -Filter ".DS_Store" -Recurse -Force -ErrorAction SilentlyContinue |
        Remove-Item -Force -ErrorAction SilentlyContinue

    Write-Host "  [OK] $($skill.Name)"
    return $true
}

function Show-Menu {
    Write-Host ""
    Write-Host "Google Android Skills Installer"
    Write-Host "================================"
    Write-Host ""
    Write-Host "Available skills:"
    Write-Host ""

    for ($i = 0; $i -lt $Skills.Count; $i++) {
        $dest = Join-Path $SkillsDir $Skills[$i].Name
        $status = if (Test-Path $dest) { "*" } else { " " }
        $num = $i + 1
        $name = $Skills[$i].Name.PadRight(40)
        Write-Host "  [$status] $num) $name $($Skills[$i].Desc)"
    }

    Write-Host ""
    Write-Host "  [*] = already installed"
    Write-Host ""
    Write-Host "Options:"
    Write-Host "  Enter numbers separated by spaces (e.g. 1 3 5)"
    Write-Host "  Ranges supported (e.g. 1-3 5)"
    Write-Host "  a = install all"
    Write-Host "  q = quit"
    Write-Host ""
}

function Parse-Selection {
    param([string]$Input)

    $indices = @()
    $tokens = $Input -split '[,\s]+' | Where-Object { $_ -ne '' }

    foreach ($token in $tokens) {
        if ($token -match '^(\d+)-(\d+)$') {
            $start = [int]$Matches[1]
            $end = [int]$Matches[2]
            for ($n = $start; $n -le $end; $n++) {
                if ($n -ge 1 -and $n -le $Skills.Count) {
                    $indices += ($n - 1)
                }
            }
        }
        elseif ($token -match '^\d+$') {
            $n = [int]$token
            if ($n -ge 1 -and $n -le $Skills.Count) {
                $indices += ($n - 1)
            }
            else {
                return $null
            }
        }
        else {
            return $null
        }
    }

    return ($indices | Sort-Object -Unique)
}

# --- Main ---

if (-not (Test-Path $SkillsDir)) {
    New-Item -ItemType Directory -Path $SkillsDir -Force | Out-Null
}

# --All flag: skip interactive menu
if ($All) {
    Write-Host "Installing all Google Android skills to $SkillsDir..."
    Write-Host ""
    $installed = 0
    for ($i = 0; $i -lt $Skills.Count; $i++) {
        if (Install-Skill -Index $i) { $installed++ }
    }
    Write-Host ""
    Write-Host "Done! Installed: $installed/$($Skills.Count)"
    Write-Host "Skills location: $SkillsDir"
    exit 0
}

# Interactive mode
Show-Menu
$choice = Read-Host "Your choice"

if ($choice -eq 'q' -or $choice -eq 'Q') {
    Write-Host "Cancelled."
    exit 0
}

if ($choice -eq 'a' -or $choice -eq 'A') {
    Write-Host ""
    Write-Host "Installing all Google Android skills to $SkillsDir..."
    Write-Host ""
    $installed = 0
    for ($i = 0; $i -lt $Skills.Count; $i++) {
        if (Install-Skill -Index $i) { $installed++ }
    }
    Write-Host ""
    Write-Host "Done! Installed: $installed/$($Skills.Count)"
    Write-Host "Skills location: $SkillsDir"
    exit 0
}

$selectedIndices = Parse-Selection -Input $choice

if ($null -eq $selectedIndices -or $selectedIndices.Count -eq 0) {
    Write-Host "Invalid selection. Please run the script again."
    exit 1
}

Write-Host ""
Write-Host "Installing $($selectedIndices.Count) skill(s) to $SkillsDir..."
Write-Host ""

$installed = 0
foreach ($idx in $selectedIndices) {
    if (Install-Skill -Index $idx) { $installed++ }
}

Write-Host ""
Write-Host "Done! Installed: $installed/$($selectedIndices.Count)"
Write-Host "Skills location: $SkillsDir"
