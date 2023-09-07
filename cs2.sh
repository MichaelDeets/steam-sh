#!/bin/sh -a

# This script was specifically designed to be ran on my computer alone.	
# You should not use this script directly, but rather as a base for a new script.

# WINESYNC requires the winesync kernel module. If you do not have this kernel
# module installed, it will not work. You should instead enable WINEESYNC or
# WINEFSYNC, and disable WINESYNC.

WINEARCH="win64"
WINEDEBUG="-all"
WINEESYNC=0
WINEFSYNC=0
WINESYNC=1

# WINE_ROOT should point to your WINE installation main folder, as it is used to
# define WINE's location. This makes it easy to use pre-built WINE forks such as
# WINE-GE. In this case, I am using the location defined by eselect in Gentoo
# where it is pointing to my compiled version of GE's fork of Valve's Proton WINE.

#WINE_ROOT=~/Games/steam/wine/wineroot
WINE_ROOT=/etc/eselect/wine/
WINE=$WINE_ROOT/bin/wine
WINESERVER=$WINE_ROOT/bin/wineserver
WINEPREFIX=~/Games/steam/wine/prefix

# For this install, we have defined a location for Steam to be installed.
# This location MUST be selected when installing Steam from SteamSetup.exe.
# By default, Steam will be installed within the WINE prefix, which can be
# extremely annoying if the prefix gets deleted.

STEAM_ROOT=~/Games/steam/steamroot/
STEAM_EXE=$STEAM_ROOT/steam.exe
STEAM_ARGS="-cef-disable-sandbox -cef-disable-seccomp-sandbox -cef-single-process -no-cef-sandbox -nocrashmonitor -nointro -novid -nojoy -no-browser -no-dwrite -cef-disable-gpu -nointro -rememberpassword -single_core"
DXVK_CONFIG_FILE="~/.config/dxvk/dxvk.conf"

# I have issues using the open-source MESA drivers, where smokes will not render
# and various visual bugs occur throughout gameplay. Defining the envvars
# VK_ICD_FILENAMES will allow you to switch from MESA to AMDVLK or even
# the AMDGPU-PRO drivers.
# Only attempt switching drivers if you find problems using MESA, otherwise you
# should always be using MESA.

#VK_ICD_FILENAMES="/usr/share/vulkan/icd.d/amd_pro_icd32.json:/usr/share/vulkan/icd.d/amd_pro_icd64.json"
#VK_ICD_FILENAMES="/etc/vulkan/icd.d/amd_icd32.json:/etc/vulkan/icd.d/amd_icd64.json"
#AMD_VULKAN_ICD=AMDVLK

# You might want to change wineboot and wineserver to the exact locations.
# This will currently use the first result from PATH, so you could also
# include the WINE installation as the first location inside PATH.
#
# Probably don't need to include the WINEPREFIX/WINE envvars, but just to
# make sure they're actually being used.

echo "--- Creating WINE prefix ---"
if [ ! -d $WINEPREFIX ]; then
	mkdir -p ~/Games/steam/wine
	$WINE_ROOT/bin/wineboot && $WINE_ROOT/bin/wineserver
	WINEPREFIX=${WINEPREFIX} winetricks msls31 riched20 andale arial comicsans impact tahoma times allfonts d3dcompiler_43 d3dcompiler_47 fontsmooth=rgb 
fi

# If you have a DXVK installation from your package manager, this will
# install the DXVK binaries inside the WINE prefix. You might need to
# change the location of setup_dxvk.sh.

echo "--- Installing DXVK ---"
if [ ! -L $WINEPREFIX/drive_c/windows/system32/d3d11.dll ]; then
	WINE=${WINE} WINEPREFIX=${WINEPREFIX} /usr/bin/setup_dxvk.sh install --symlink
fi

# Taken directly from csgo.sh.
# I like to include multiple .sh scripts containing various settings and envvars.
# One before the while loop, and one after.
#
# You might need to use either "source" or simply a "." before the script location
# to actually load. I have success using the latter. 

echo "--- Launching Steam ---"
STATUS=42
cd $STEAM_ROOT
while [ $STATUS -eq 42 ]; do
	$WINE $STEAM_EXE $STEAM_ARGS
	STATUS=$?
done
exit $STATUS
