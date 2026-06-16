function brew-edit --description "Edit a Homebrew bundle file"
    chezmoi edit $HOMEBREW_BUNDLE_FILE
    chezmoi apply --verbose $HOMEBREW_BUNDLE_FILE
end
