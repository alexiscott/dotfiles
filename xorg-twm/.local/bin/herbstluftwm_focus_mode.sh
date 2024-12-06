#!/bin/bash

# herbstluftwm_focus_mode --- Focus modus for my HerbstluftWM
#
# Copyright (c) 2021-2023  Protesilaos Stavrou <info@protesilaos.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.	See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.	If not, see <https://www.gnu.org/licenses/>.

command -v polybar > /dev/null || { echo "ERROR: no polybar available"; exit 1; }

# We use this method instead of 'herbstclient get' because it gives us
# the preferred value of the configuration.
_get_value ()
{
    local autostart
    autostart="$HOME/.config/herbstluftwm/autostart"

    sed "/$1/!d ; s,.* $1 \([a-z0-9]*\).*,\1," "$autostart"
}

smart_window_surroundings="$(_get_value smart_window_surroundings)"
smart_frame_surroundings="$(_get_value smart_frame_surroundings)"
frame_border_width="$(_get_value frame_border_width)"

# This is used by the 'delight.sh' script.
focus_mode_status="$HOME"/.config/prot-xtwm-focus-mode

_hc ()
{
    herbstclient "$@"
}

if pgrep -x polybar
then
    _hc set smart_window_surroundings on
    _hc set smart_frame_surroundings on
    _hc set frame_border_width 0

    echo "on" > "$focus_mode_status"

    pkill -x polybar
else
    _hc set smart_window_surroundings "$smart_window_surroundings"
    _hc set smart_frame_surroundings "$smart_frame_surroundings"
    _hc set frame_border_width "$frame_border_width"

    echo "off" > "$focus_mode_status"

    # I name my bars after the bspwm or herbstluftwm sessions, so I
    # launch the one I need by getting the relevant environment
    # variable.
    polybar -rq "$DESKTOP_SESSION" &
fi
