# Auto-start Hyprland on TTY login (via uwsm — Hyprland's recommended launch method).
if status is-login; and command -q uwsm
    if uwsm check may-start
        exec uwsm start hyprland.desktop
    end
end
