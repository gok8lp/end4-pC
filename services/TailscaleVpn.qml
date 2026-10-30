pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

/**
 * Tailscale durumu + tek tuşla aç/kapat (çubuk simgesi için). Mullvad'a dokunmaz; yalnız durumunu okur.
 * Veri kaynağı: ~/.local/bin/tailscale-durum  ("ts=running mullvad=connected peers=2")
 */
Singleton {
    id: root

    property string ts: "yok"
    property string mullvad: "yok"
    property int peers: 0
    property bool busy: false

    readonly property bool available: ts !== "yok"
    readonly property bool connected: ts === "running"
    // Mullvad bağlıyken Tailscale IP trafiği Mullvad güvenlik duvarınca engellenir
    readonly property bool conflict: connected && mullvad === "connected"

    readonly property string tooltip: {
        if (!available) return "Tailscale bulunamadı";
        if (conflict) return "Tailscale AÇIK ama Mullvad bağlı: Tailscale IP trafiği engelleniyor (LAN çalışır). Tıkla: kapat";
        if (connected) return `Tailscale bağlı • ${peers} cihaz çevrimiçi${mullvad === "connected" ? " • Mullvad bağlı" : ""}. Tıkla: kapat`;
        return "Tailscale kapalı. Tıkla: aç";
    }

    function refresh() {
        if (!statusProc.running) statusProc.running = true;
    }

    function toggle() {
        if (root.busy) return;
        root.busy = true;
        Quickshell.execDetached([Quickshell.env("HOME") + "/.local/bin/tailscale-anahtar"]);
        settleTimer.restart();
    }

    Timer {
        id: settleTimer
        interval: 3500
        onTriggered: {
            root.busy = false;
            root.refresh();
        }
    }

    Timer {
        interval: 6000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }

    Process {
        id: statusProc
        command: [Quickshell.env("HOME") + "/.local/bin/tailscale-durum"]
        stdout: StdioCollector {
            onStreamFinished: {
                const m = text.match(/ts=(\w+)\s+mullvad=(\w+)\s+peers=(\d+)/);
                if (!m) return;
                root.ts = m[1];
                root.mullvad = m[2];
                root.peers = parseInt(m[3]);
            }
        }
    }
}
