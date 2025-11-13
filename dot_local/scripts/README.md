# User Scripts

This directory (`~/.local/scripts/`) contains custom scripts that can be run via the `starship-scripts` launcher.

## Usage

Run the launcher from anywhere:

```bash
starship-scripts
```

This will display an interactive menu of all executable scripts in this directory.

## Adding New Scripts

1. Create your script in this directory
2. Add a shebang line: `#!/usr/bin/env bash`
3. (Optional) Add a NAME header for custom display name:

   ```bash
   # NAME: My Custom Script
   ```

4. Make it executable:

   ```bash
   chmod +x your-script.sh
   ```

## Display Names

Scripts can specify their display name in two ways:

1. **NAME header (recommended)**: Add `# NAME: Your Display Name` in the first 10 lines

   ```bash
   #!/usr/bin/env bash
   # NAME: Deploy to Production
   # This is my deployment script
   ```

2. **Filename fallback**: If no NAME header exists, the filename is converted:
   - `deploy-prod.sh` → "Deploy Prod"
   - `backup_database.sh` → "Backup Database"

## Example Scripts

This directory includes three example scripts:

- `example-hello.sh` - Demonstrates NAME header
- `example-test-failure.sh` - Shows error handling
- `backup-files.sh` - Shows filename fallback (no NAME header)

Feel free to delete these examples once you've added your own scripts.

## Script Standards

Follow the shell script standards from `AGENTS.md`:

```bash
#!/usr/bin/env bash
set -euo pipefail

# Your script here
```

- Use `set -euo pipefail` for safety
- Quote all variables: `"$VAR"`
- Use `command -v` to check for tools
- Make scripts idempotent when possible