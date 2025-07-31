#!/bin/bash
# This script ensures VS Code opens files in an existing window,
# and then switches to the workspace where that VS Code window is located.
# The class name for VS Code windows in Hyprland is typically "Code".
VSCODE_WINDOW_CLASS="code"
TARGET_WORKSPACE="2" # The workspace where you want VS Code to live

# Find the workspace of an existing VS Code window
# hyprctl clients -j outputs JSON, we parse it with jq
# We look for a window with class "Code" and extract its workspace ID.
# We take the first one found.
VSCODE_WORKSPACE_ID=$(hyprctl clients -j | jq -r --arg CLASS "$VSCODE_WINDOW_CLASS" '.[] | select(.class == $CLASS) | .workspace.id' | head -n 1)

# Get the current active workspace ID
CURRENT_WORKSPACE_ID=$(hyprctl monitors -j | jq -r '.[] | select(.focused == true) | .activeWorkspace.id')

# If a VS Code window was found on a specific workspace
if [[ -n "$VSCODE_WORKSPACE_ID" ]]; then
    # If the VS Code workspace is different from the current workspace, switch to it.
    if [[ "$VSCODE_WORKSPACE_ID" -ne "$CURRENT_WORKSPACE_ID" ]]; then
        hyprctl dispatch workspace "$VSCODE_WORKSPACE_ID"
    fi
else
    # If no VS Code window is found, it means a new one will be launched.
    # In this case, we'll switch to the TARGET_WORKSPACE (Workspace 2)
    # before launching, so the new window appears there directly.
    if [[ "$TARGET_WORKSPACE" -ne "$CURRENT_WORKSPACE_ID" ]]; then
        hyprctl dispatch workspace "$TARGET_WORKSPACE"
    fi
fi

# Now, open the file(s) in VS Code.
# The --reuse-window flag ensures it uses an existing instance if available.
# The '&' runs it in the background so the script doesn't wait for VS Code to close.
/usr/bin/code --reuse-window "$@" &

exit 0
