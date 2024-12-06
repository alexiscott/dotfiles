#!/bin/bash

# herbstluftwm_cycle_monitors --- Cycle HerbstluftWM monitor layouts.
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

monitor_count="$(herbstclient list_monitors | wc -l)"

_smart_borders ()
{
    herbstclient set smart_frame_surroundings "$1"
    herbstclient set smart_window_surroundings "$1"
}

case "$monitor_count"
in
    1) herbstclient set_monitors 640x1080+0+0 1920x1080+640+0 && _smart_borders 'off' ;;
    2) herbstclient set_monitors 620x1080+0+0 1320x1080+620+0 620x1080+1940+0  && _smart_borders 'off' ;;
    *) herbstclient detect_monitors && _smart_borders 'on' ;;
esac
