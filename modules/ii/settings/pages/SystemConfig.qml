import QtQuick
import QtQuick.Layouts
import Quickshell
import qs
import qs.services
import qs.modules.common
import qs.modules.common.widgets

ContentPage {
    id: page
    forceWidth: true
    bottomContentPadding: 15

    function run(cmd) { Quickshell.execDetached(["bash", "-lc", cmd]); }
    function kcm(module) { page.run("kcmshell6 " + module); }

    component SysGrid: GridLayout {
        Layout.fillWidth: true
        columns: 2
        columnSpacing: 8
        rowSpacing: 8
    }

    component SysButton: RippleButtonWithIcon {
        property string cmd: ""
        Layout.fillWidth: true
        Layout.preferredHeight: 46
        onClicked: if (cmd !== "") page.run(cmd)
    }

    ColumnLayout {
        Layout.fillWidth: true
        spacing: 20

        ContentSection {
            icon: "wifi"
            title: Translation.tr("Network & connections")
            SysGrid {
                SysButton { materialIcon: "wifi"; mainText: Translation.tr("Wi-Fi & network"); cmd: "foot -e nmtui" }
                SysButton { materialIcon: "bluetooth"; mainText: "Bluetooth"; cmd: "blueman-manager" }
                SysButton { materialIcon: "lan"; mainText: Translation.tr("Proxy"); cmd: "kcmshell6 kcm_proxy" }
                SysButton { materialIcon: "cloud"; mainText: Translation.tr("Online accounts"); cmd: "kcmshell6 kcm_kaccounts" }
            }
        }

        ContentSection {
            icon: "desktop_windows"
            title: Translation.tr("Display & sound")
            SysGrid {
                SysButton {
                    materialIcon: "monitor"
                    mainText: Translation.tr("Monitors, resolution & scale")
                    onClicked: GlobalStates.openSettingsAt("hyprland", "", "", "")
                }
                SysButton { materialIcon: "volume_up"; mainText: Translation.tr("Sound devices & volume"); cmd: "pavucontrol" }
                SysButton { materialIcon: "bedtime"; mainText: Translation.tr("Night light"); cmd: "kcmshell6 kcm_nightlight" }
                SysButton { materialIcon: "notifications"; mainText: Translation.tr("Notifications"); cmd: "kcmshell6 kcm_notifications" }
            }
        }

        ContentSection {
            icon: "bolt"
            title: Translation.tr("Power")
            SysGrid {
                columns: 3
                SysButton { materialIcon: "speed"; mainText: Translation.tr("Performance"); cmd: "powerprofilesctl set performance" }
                SysButton { materialIcon: "balance"; mainText: Translation.tr("Balanced"); cmd: "powerprofilesctl set balanced" }
                SysButton { materialIcon: "eco"; mainText: Translation.tr("Power saver"); cmd: "powerprofilesctl set power-saver" }
            }
            SysGrid {
                SysButton { materialIcon: "battery_charging_full"; mainText: Translation.tr("Power management"); cmd: "kcmshell6 kcm_powerdevilprofilesconfig" }
                SysButton { materialIcon: "lock"; mainText: Translation.tr("Screen locking"); cmd: "kcmshell6 kcm_screenlocker" }
            }
        }

        ContentSection {
            icon: "keyboard"
            title: Translation.tr("Input & language")
            SysGrid {
                SysButton {
                    materialIcon: "keyboard"
                    mainText: Translation.tr("Keyboard & mouse")
                    onClicked: GlobalStates.openSettingsAt("hyprland", "Input", "", "")
                }
                SysButton {
                    materialIcon: "touchpad_mouse"
                    mainText: Translation.tr("Touchpad (speed, scrolling, taps)")
                    onClicked: GlobalStates.openSettingsAt("hyprland", "Touchpad", "", "")
                }
                SysButton { materialIcon: "language"; mainText: Translation.tr("Region & language"); cmd: "kcmshell6 kcm_regionandlang" }
            }
        }

        ContentSection {
            icon: "palette"
            title: Translation.tr("Appearance")
            SysGrid {
                SysButton { materialIcon: "wallpaper"; mainText: Translation.tr("Wallpaper"); onClicked: GlobalStates.wallpaperSelectorOpen = true }
                SysButton { materialIcon: "palette"; mainText: Translation.tr("Colors"); cmd: "kcmshell6 kcm_colors" }
                SysButton { materialIcon: "text_fields"; mainText: Translation.tr("Fonts"); cmd: "kcmshell6 kcm_fonts" }
                SysButton { materialIcon: "category"; mainText: Translation.tr("Icons"); cmd: "kcmshell6 kcm_icons" }
                SysButton { materialIcon: "mouse"; mainText: Translation.tr("Cursor"); cmd: "kcmshell6 kcm_cursortheme" }
                SysButton { materialIcon: "animation"; mainText: Translation.tr("Animations"); cmd: "kcmshell6 kcm_animations" }
            }
        }

        ContentSection {
            icon: "apps"
            title: Translation.tr("Apps")
            SysGrid {
                SysButton { materialIcon: "web_asset"; mainText: Translation.tr("Default applications"); cmd: "kcmshell6 kcm_componentchooser" }
                SysButton { materialIcon: "description"; mainText: Translation.tr("File associations"); cmd: "kcmshell6 kcm_filetypes" }
                SysButton { materialIcon: "rocket_launch"; mainText: Translation.tr("Startup apps"); cmd: "kcmshell6 kcm_autostart" }
                SysButton { materialIcon: "print"; mainText: Translation.tr("Printers"); cmd: "system-config-printer" }
            }
        }

        ContentSection {
            icon: "settings_suggest"
            title: Translation.tr("System")
            SysGrid {
                SysButton { materialIcon: "group"; mainText: Translation.tr("Users"); cmd: "kcmshell6 kcm_users" }
                SysButton { materialIcon: "monitor_heart"; mainText: Translation.tr("System monitor"); cmd: "foot -e btop" }
            }
        }
    }
}
