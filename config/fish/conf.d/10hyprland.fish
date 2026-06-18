# Auto-start Hyprland on TTY login (via uwsm — Hyprland's recommended launch method).
#
# This file is shared across all devices but is inert anywhere Hyprland isn't:
#   - `command -q uwsm` is only true on the Linux/Hyprland host (uwsm isn't
#     installed on macOS or WSL), so this no-ops everywhere else.
#   - `status is-login` limits it to login shells, so terminals opened inside
#     Hyprland don't re-trigger it.
#   - `uwsm check may-start` is false when a graphical session already exists.
if status is-login; and command -q uwsm
    if uwsm check may-start
        exec uwsm start hyprland.desktop
    end
end
