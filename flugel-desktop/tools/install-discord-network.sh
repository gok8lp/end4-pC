#!/usr/bin/env bash
# Install code and service files only; VPN credentials stay in the Mullvad installation.
set -euo pipefail
[[ $EUID == 0 ]] || { echo 'Run with sudo after reviewing this script.' >&2; exit 1; }
[[ $(id -u flugel) == 1000 ]] || { echo 'This snapshot targets flugel (UID 1000); adapt the helper and sudoers first.' >&2; exit 1; }
command -v wg >/dev/null || { echo 'Install wireguard-tools first.' >&2; exit 1; }
[[ -s /etc/mullvad-vpn/device.json ]] || { echo 'Sign in to Mullvad first; leave the global VPN disconnected.' >&2; exit 1; }
root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
backup=/var/backups/flugel-desktop-$(date +%Y%m%d-%H%M%S)
for rel in usr/local/libexec/discord-mullvad-network usr/local/libexec/discord-mullvad-run etc/systemd/system/discord-mullvad.service etc/netns/discord-mullvad/resolv.conf etc/netns/discord-mullvad/nsswitch.conf etc/sudoers.d/discord-mullvad; do
    if [[ -e /$rel ]]; then
        mkdir -p "$backup/$(dirname "$rel")"
        cp -a "/$rel" "$backup/$rel"
    fi
    mode=644
    case "$rel" in usr/local/libexec/*) mode=755 ;; etc/sudoers.d/*) mode=440 ;; esac
    install -D -o root -g root -m "$mode" "$root/system/$rel" "/$rel"
done
visudo -cf /etc/sudoers.d/discord-mullvad
systemctl daemon-reload
printf 'Installed. Discord starts the VPN network on demand. Previous files: %s\n' "$backup"
