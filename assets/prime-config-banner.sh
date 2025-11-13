#!/usr/bin/env bash
# Prime Config ASCII Art Banner (Gum-based - Perfect alignment everywhere)
# Requires: gum (https://github.com/charmbracelet/gum)
# Source this file or run it directly to display the banner

# Check if gum is available
if ! command -v gum &> /dev/null; then
    echo "Error: gum is required but not installed."
    echo "Install with: brew install gum"
    exit 1
fi

# Build the content
gum style \
  --border rounded \
  --border-foreground 240 \
  --width 60 \
  --padding "0 1" \
  "$(gum style --foreground 250 '                                                      ·  ✦')" \
  "$(gum style --foreground 212 --bold '   ██████╗ ██████╗ ██╗███╗   ███╗███████╗')          $(gum style --foreground 250 '·')" \
  "$(gum style --foreground 212 --bold '   ██╔══██╗██╔══██╗██║████╗ ████║██╔════╝')    $(gum style --foreground 255 '✦')" \
  "$(gum style --foreground 212 --bold '   ██████╔╝██████╔╝██║██╔████╔██║█████╗')              $(gum style --foreground 250 '·')" \
  "$(gum style --foreground 250 '·') $(gum style --foreground 212 --bold '██╔═══╝ ██╔══██╗██║██║╚██╔╝██║██╔══╝')       $(gum style --foreground 255 '✦')" \
  "$(gum style --foreground 212 --bold '   ██║     ██║  ██║██║██║ ╚═╝ ██║███████╗')" \
  "$(gum style --foreground 212 --bold '   ╚═╝     ╚═╝  ╚═╝╚═╝╚═╝     ╚═╝╚══════╝')         $(gum style --foreground 250 '·')" \
  "$(gum style --foreground 255 '✦')" \
  "$(gum style --foreground 81 --bold '    ██████╗ ██████╗ ███╗   ██╗███████╗██╗ ██████╗')    $(gum style --foreground 250 '·')" \
  "$(gum style --foreground 81 --bold '   ██╔════╝██╔═══██╗████╗  ██║██╔════╝██║██╔════╝')" \
  "$(gum style --foreground 250 '·') $(gum style --foreground 81 --bold '██║     ██║   ██║██╔██╗ ██║█████╗  ██║██║  ███╗')    $(gum style --foreground 255 '✦')" \
  "$(gum style --foreground 81 --bold '   ██║     ██║   ██║██║╚██╗██║██╔══╝  ██║██║   ██║')" \
  "$(gum style --foreground 81 --bold '   ╚██████╗╚██████╔╝██║ ╚████║██║     ██║╚██████╔╝')  $(gum style --foreground 250 '·')" \
  "$(gum style --foreground 81 --bold '    ╚═════╝ ╚═════╝ ╚═╝  ╚═══╝╚═╝     ╚═╝ ╚═════╝')" \
  "     $(gum style --foreground 255 '✦')                                              $(gum style --foreground 250 '·')" \
  "              $(gum style --foreground 221 --bold '🖖 Configuration, the Prime way')" \
  "          $(gum style --foreground 250 '·')                                            $(gum style --foreground 255 '✦')"
