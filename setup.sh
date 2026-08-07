mkdir -p ~/.config

for file in $(pwd -P)/config/*; do
    echo "Installing $file"
    if [ "$file" = "$(pwd -P)/config/claude" ]; then
        # claude rewrites its own settings; copy so machine-local churn stays out of the repo
        mkdir -p "$HOME/.config/claude"
        cp "$file"/* "$HOME/.config/claude"
    else
        ln -sf "$file" "$HOME/.config"
    fi
done
unset file
