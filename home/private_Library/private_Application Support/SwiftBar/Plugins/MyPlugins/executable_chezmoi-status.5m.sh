#!/usr/bin/env bash

# <xbar.title>Chezmoi Status</xbar.title>
# <xbar.version>v1.0</xbar.version>
# <xbar.author>bosper351</xbar.author>
# <xbar.author.github>bosper351</xbar.author.github>
# <xbar.desc>Shows Chezmoi status</xbar.desc>
# <xbar.dependencies>chezmoi</xbar.dependencies>


ICON="iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAYAAADgdz34AAAACXBIWXMAABYlAAAWJQFJUiTwAAAAGXRFWHRTb2Z0d2FyZQB3d3cuaW5rc2NhcGUub3Jnm+48GgAAAKdJREFUSIntlssNwyAQBWdTASW4BJeSElJKSnIJlEAJlJBU8HzBEvkameXmlZ7EO+yMkDhgkmgZMwvAAmRJt6YlAEm7AQKQAJVEIDTtHoBvSS2So/BmSQ+8SdIL35V4wP9KvOA/JZ7wrxJv+IdkBPxFwiD4loWqZCdoBh7VmStwL9fxEERgLsz5/Zm6CGrmhcFzCk6Bv+DpwEx1sfrbYmYTMPXQJcW6rxwfAtK24CrJAAAAAElFTkSuQmCC"

PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:$PATH"
script_path="$(realpath "$0")"

# Check if chezmoi is installed
if ! command -v chezmoi &> /dev/null; then
    exit 1
fi

# Function to sync git
sync_git() {
    if [ -z "$(chezmoi git -- status --porcelain)" ]; then
        chezmoi git -- pull && chezmoi git -- push
    else
        chezmoi git -- push
    fi
}

# Function to show diff
show_diff() {
    chezmoi diff
    exit 0
}

# Function to add file
add_file() {
    chezmoi add "$1"
}

# Function to apply file
apply_file() {
    chezmoi apply --force --verbose "$1"
}

# Function to diff file
diff_file() {
    chezmoi diff "$1"
}



# Function to render the menu
render() {
    # Get chezmoi status (managed files)
    chezmoi_status=$(chezmoi status 2>/dev/null)

    # Get chezmoi git status
    chezmoi_git_status=$(chezmoi git -- status --porcelain 2>/dev/null)
    Check for pending changes
    if [ -n "$chezmoi_status" ] || [ -n "$chezmoi_git_status" ]; then
        echo "⇅ | templateImage=$ICON"
    else
        echo "| templateImage=$ICON"
    fi

    # Dropdown menu for changes
    echo "---"
    echo "Chezmoi Changes"
    if [ -n "$chezmoi_status" ]; then
        while IFS= read -r line; do
            if [ -n "$line" ]; then
                status=${line:0:2}
                file=${line:3}
                echo "-- $status $file"
                echo "-- Add | shell=\"$script_path\" param1=add param2=\"$file\" terminal=true"
                echo "-- Apply | shell=\"$script_path\" param1=apply param2=\"$file\" terminal=true"
                echo "-- Diff | shell=\"$script_path\" param1=diff param2=\"$file\" terminal=true"
                echo "-----"
            fi
        done <<< "$chezmoi_status"
    fi

    echo "---"
    echo "Git Changes"
    if [ -n "$chezmoi_git_status" ]; then
        while IFS= read -r line; do
            if [ -n "$line" ]; then
                status=${line:0:2}
                file=${line:3}
                echo "-- $status: $file"
            fi
        done <<< "$chezmoi_git_status"
    fi

    echo "---"
    echo "Refresh | refresh=true"
    git_sync_disabled=$([ -n "$chezmoi_git_status" ] && echo "true" || echo "false")
    echo "Sync Git | shell=\"$script_path\" param1=sync_git terminal=false disabled=$git_sync_disabled"

    # Disable Show Diff and Add All when there are no chezmoi changes
    chezmoi_actions_disabled=$([ -n "$chezmoi_status" ] && echo "false" || echo "true")
    echo "Show Diff | shell=\"$script_path\" param1=show_diff terminal=true disabled=$chezmoi_actions_disabled"
    echo "Add All | shell=\"$script_path\" param1=add_all terminal=false refresh=true disabled=$chezmoi_actions_disabled"
}

main() {
    if [ "$1" = "sync_git" ]; then
        sync_git
    elif [ "$1" = "show_diff" ]; then
        show_diff
    elif [ "$1" = "add" ]; then
        # Files with spaces in name are passed here as separate arguments
        declare -a args=("$@")
        add_file "${args[*]:1}"
    elif [ "$1" = "apply" ]; then
        declare -a args=("$@")
        apply_file "${args[*]:1}"
    elif [ "$1" = "diff" ]; then
        declare -a args=("$@")
        diff_file "${args[*]:1}"
    elif [ "$1" = "add_all" ]; then
        chezmoi re-add
    else
        render
    fi
}

main "$@"
