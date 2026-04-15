## Android skills

Android skills are a dedicated repository of AI-optimised, modular instructions and resources, to
help LLMs better understand and execute specific patterns that follow the best practices and
guidance on Android development from [developer.android.com](developer.android.com).

Android skills follow the [open-standard agent skills](https://agentskills.io/home) - markdown
files (SKILL.md) that provide a technical specification of a task, and ground LLMs with information
on specialized domains and workflows.

## Installation

The installer scripts copy skills to `~/.claude/skills/` for use with Claude Code. Each script
supports two modes:

- **Interactive mode** — presents a menu to choose which skills to install
- **Install all** — installs every available skill without prompting

### macOS / Linux (Bash)

```bash
# Interactive mode
./install.sh

# Install all skills
./install.sh --all
```

### Windows (PowerShell)

```powershell
# Interactive mode
./install.ps1

# Install all skills
./install.ps1 -All
```

### Windows (cmd)

```cmd
REM Interactive mode
install.bat

REM Install all skills
install.bat --all
```

### Interactive menu

When running in interactive mode, the installer displays a numbered list of available skills:

| # | Skill | Description |
|---|-------|-------------|
| 1 | agp-9-upgrade | Upgrade Android Gradle Plugin to version 9 |
| 2 | migrate-xml-views-to-jetpack-compose | Migrate XML views to Jetpack Compose |
| 3 | navigation-3 | Migrate to Navigation 3 |
| 4 | r8-analyzer | Analyze R8/ProGuard rules for optimization |
| 5 | play-billing-library-version-upgrade | Upgrade Play Billing Library version |
| 6 | edge-to-edge | Migrate to edge-to-edge display |

You can enter:
- Individual numbers separated by spaces (e.g. `1 3 5`)
- Ranges (e.g. `1-3 5`)
- `a` to install all
- `q` to quit

Already-installed skills are marked with `[*]` in the menu.

## Usage

To use Android skills after installation, check your agent's documentation.

## Disclaimer

AI can make mistakes, so always double-check the results.

## Contributing

Submit a GitHub issue to provide feedback, report issues, or make new skill requests and changes.

Public contributions are not accepted at this time.

## License

Android Skills is licensed under the [Apache License 2.0](LICENSE.txt). See the `LICENSE.txt` file
for
details.

## Review our community guidelines

This project follows
[Google's Open Source Community Guidelines](https://opensource.google/conduct/).