for file in $(pwd -P)/config/*; do
    echo "Installing $file"
    ln -sf "$file" "$HOME/.config"
done
unset file
