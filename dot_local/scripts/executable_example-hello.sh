#!/usr/bin/env bash
# NAME: Say Hello
# A simple example script that greets the user

set -euo pipefail

echo "Hello from Starship Scripts!"
echo ""
echo "This is an example script demonstrating the launcher."
echo "It has a '# NAME:' header for a custom display name."
echo ""
echo "Script location: $0"
echo "Current user: $(whoami)"
echo "Current directory: $(pwd)"
echo ""
echo "Press any key to return to menu..."
read -n 1 -s
