#!/bin/bash

# poweroptionsmenu --- rofi or dmenu interface for session actions.
#
# Copyright (c) 2019-2024 Protesilaos Stavrou <info@protesilaos.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
#
# Dependency:
#    rofi OR dmenu

_pkill() {
    if pgrep -x "$1"; then
        pkill -x "$1"
    fi
}

_kill_processes() {
    _pkill bspwm_external_rules.sh
    _pkill sxhkd
    _pkill polybar
    _pkill feh
    _pkill picom
}

# In case something stops working, we can call this script
# (Ctrl+Alt+Delete on my sxhkdrc) and apply the modifications again.
_kbd_reset() {
    setxkbmap -layout 'us,gr' -option '' -option 'ctrl:nocaps' \
              -option 'altwin:menu_win' -option 'caps:none' \
              -option 'compose:ins' -option 'grp:win_space_toggle'
}

_check_systemd() {
    case "$(cat /proc/1/comm)"
    in
        "systemd")
            systemctl "$1"
            ;;
        #  TODO 2023-03-08: Cover openrc, runit, shepherd.
        *)
            sudo "$1"
            ;;
    esac
}

# The idea with _reboot() and _poweroff() is to use the appropriate
# command depending on whether the machine is running systemd or not.
#
# The `reboot' and `poweroff' require escalated privileges.  Read:
# https://wiki.voidlinux.org/Post_Installation#Allow_users_to_shutdown_without_a_password
_reboot() {
    _check_systemd 'reboot'
}

_poweroff() {
    _check_systemd 'poweroff'
}

_quit()
{
    case "$DESKTOP_SESSION"
    in
        bspwm) bspc quit ;;
        i3) i3-msg -t command exit ;;
        herbstluftwm) herbstclient quit ;;
    esac
}

_checkdep() {
    command -v "$1" > /dev/null || return 1
}

_dynamic_menu() {
    if _checkdep rofi; then
        # use printf to output array items on a new line
        rofi -dmenu -i -no-custom -p 'Power options'
    elif _checkdep dmenu; then
        dmenu -i -p 'Power options'
    else
        echo "Missing rofi or dmenu dependency." && exit 1
    fi
}

# Possible actions
actions=('Log out' 'Reboot' 'Keyboard reset' 'Power off')

# List actions to choose from.  Output array items on a new line.
_list_actions() {
    printf '%s\n' "${actions[@]}" | _dynamic_menu
}

choice="$(_list_actions)"

# Run the selected command.
case "$choice" in
    L*) _kill_processes && _quit     ;;
    R*) _kill_processes && _reboot   ;;
    P*) _kill_processes && _poweroff ;;
    K*) _kbd_reset                   ;;
esac
