#!/bin/bash

# bspwm_adjust_gaps --- Change window gaps in focused BSPWM desktop.
#
# Copyright (c) 2023-2024  Protesilaos Stavrou <info@protesilaos.com>
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

window_gap_current=$(bspc config -d focused window_gap)
window_gap_increment=${1-0}
window_gap_new=$(($window_gap_current + $window_gap_increment))

# Make it cyclic.
if [ $window_gap_new -lt 0 ]
then
    window_gap_new=30
elif [ $window_gap_new -gt 30 ]
then
    window_gap_new=0
fi

bspc config -d focused window_gap $window_gap_new
