#!/bin/bash

. /opt/muos/script/var/func.sh

echo app >/tmp/act_go

# Define paths and commands
LOVEDIR="$(GET_VAR "device" "storage/rom/mount")/MUOS/application/IPTVCutter"
GPTOKEYB="$(GET_VAR "device" "storage/rom/mount")/MUOS/emulator/gptokeyb/gptokeyb2.armhf"
BINDIR="$LOVEDIR/bin"

# Export environment variables
export SDL_GAMECONTROLLERCONFIG_FILE="/usr/lib/gamecontrollerdb.txt"
export LD_LIBRARY_PATH="$BINDIR/libs.aarch64:$LD_LIBRARY_PATH"

# Launcher
cd "$LOVEDIR" || exit
SET_VAR "system" "foreground_process" "love"

# Run Application
$GPTOKEYB "love" &
./bin/love .
kill -9 "$(pidof gptokeyb2.armhf)"
