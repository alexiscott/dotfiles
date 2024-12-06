#!/bin/bash

# repaint_terminals --- Live update term colours using ANSI escape sequences.
#
# Copyright (c) 2019-2023  Protesilaos Stavrou <info@protesilaos.com>
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
## Description
#
# Use ANSI codes to apply theme change to all active terminals.  This is
# particularly useful for programs that source their colours at startup,
# requiring a restart to apply a new theme.  All terminals I have tested
# respond to the live theme change.  Tried with xterm, rxvt-unicode,
# {gnome,mate,xfce4}-terminal, kitty, tilix.
#
# The ANSI escape sequences are defined in this document
# http://pod.tst.eu/http://cvs.schmorp.de/rxvt-unicode/doc/rxvt.7.pod#XTerm_Operating_System_Commands

xrdb_col="$(xrdb -query -all | sed '/*color\|foreground\|background*/!d')"

[ -n "$xrdb_col" ] || { echo "ERROR: no xrdb colours."; exit 1; }

# Extract only the colour value of the item passed as an argument.
#
# Normally each line looks like:
#   xterm*color10:  #315b00
# It becomes:
#   #315b00
# NOTE we pass `-w` to `grep` to make sure it matches only whole words.
# Otherwise a 'foreground' would also capture 'foregroundalt'.
_get_hex_value() {
    echo "$xrdb_col" | grep -w "$1" | sed 's,.*\(#[a-zA-Z0-9]*\),\1,'
}

# Define ANSI sequences as an empty string (to be incremented).  We will
# be creating the sequence and then pass it to all running terminals, to
# update their corresponding colours.
ansi_sequences=""

# Prepare ANSI sequences for colors 0-15.
for i in {0..15}; do
    ansi_sequences+="\\033]4;${i};$(_get_hex_value color"${i}")\\007"
done

# Update base values (outside the 16-colour palette).  This covers the
# foreground, background, and cursor.
ansi_sequences+="\\033]10;$(_get_hex_value foreground)\\007"
ansi_sequences+="\\033]11;$(_get_hex_value background)\\007"
ansi_sequences+="\\033]17;$(_get_hex_value foreground)\\007"

# Apply ANSI sequences to running terminals.
for term in /dev/pts/[0-4]*; do
    printf "%b" "$ansi_sequences" > "$term" &
done
