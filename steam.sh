#!/bin/sh -a

# This script was specifically designed to be ran on my computer alone.	 You should not use this script directly, but rather as a base for a new script.
# WINESYNC requires the winesync kernel module. If you do not have this kernel module installed, it will not work. You should instead enable WINEESYNC
# or WINE FSYNC, and disable WINESYNC.

WINEARCH="win64"
WINEDEBUG="-all"
WINEESYNC=0
WINEFSYNC=0
WINESYNC=1

# WINE_ROOT should point to your WINE installation main folder, as it is used to define WINE's location. This makes it easy to use pre-built WINE forks such
# as WINE-GE. In this case, I am using the location defined by eselect in Gentoo where it is pointing to my compiled version of GE's fork of Valve's Proton WINE.

# We are setting up the location inside ~/Games/steam-wine, feel free to change the location by changing the BASE_INSTALL location

BASE_INSTALL="~/Games/steam-wine"

#WINE_ROOT=/etc/eselect/wine/
WINE_ROOT=$BASE_INSTALL/wine/wineroot
WINE=$WINE_ROOT/bin/wine
WINESERVER=$WINE_ROOT/bin/wineserver
WINEPREFIX=$BASE_INSTALL/wine/prefix

# For this install, we have defined a location for Steam to be installed. This location MUST be selected when installing Steam from SteamSetup.exe.
# By default, Steam will be installed within the WINE prefix, which can be extremely annoying if the prefix gets deleted.

STEAM_ROOT=$BASE_INSTALL/steamroot/
STEAM_EXE=$STEAM_ROOT/steam.exe
STEAM_ARGS="-nointro"
DXVK_CONFIG_FILE="~/.config/dxvk/dxvk.conf"

# I previously had issues were MESA would not render smokes, with or without vulkan; these issues were due to compiling MESA with -Ofast, more specifically
# one of the flags -Ofast enables.
# Only attempt switching drivers if you find problems using MESA, otherwise you should always be using MESA.

# For AMDGPU-PRO you should define the ICD filename locations
#VK_ICD_FILENAMES="/usr/share/vulkan/icd.d/amd_pro_icd64.json"

# For AMDVLK, instead use the envvar:
#AMD_VULKAN_ICD=AMDVLK

# Rather than using the default WINE prefix location (~/.wine), we will have the prefix installed locally at the location defined before.
# Probably don't need to include the WINEPREFIX/WINE envvars, but just to make sure they're actually being used.
# These winetricks variables were taken from the Lutris Steam install script, so I would assume they are correct.

echo "--- Creating WINE prefix ---"
if [ ! -d $WINEPREFIX ]; then
	mkdir -p $WINEPREFIX
	$WINE_ROOT/bin/wineboot && $WINE_ROOT/bin/wineserver
	WINEPREFIX=${WINEPREFIX} winetricks msls31 riched20 andale arial comicsans impact tahoma times allfonts d3dcompiler_43 d3dcompiler_47 fontsmooth=rgb 
fi

# If you have a DXVK installation from your package manager, this will install the DXVK binaries inside the WINE prefix.
# You might need to change the location of setup_dxvk.sh, if it does not exist, you can download it from here:

# https://raw.githubusercontent.com/doitsujin/dxvk/4f90d7bf5f9ad785660507e0cb459a14dab5ac75/setup_dxvk.sh

# and change the script accordingly, otherwise just comment this out.

echo "--- Installing DXVK ---"
if [ ! -L $WINEPREFIX/drive_c/windows/system32/d3d11.dll ]; then
	WINE=${WINE} WINEPREFIX=${WINEPREFIX} /usr/bin/setup_dxvk.sh install --symlink
fi

# Taken directly from csgo.sh.
# I like to include multiple .sh scripts containing various settings and envvars.
# One before the while loop, and one after.

# You might need to use either "source" or simply a "." before the script location for it to actually load. I have success using the latter. 

echo "--- Launching Steam ---"
STATUS=42
cd $STEAM_ROOT
while [ $STATUS -eq 42 ]; do
	$WINE $STEAM_EXE $STEAM_ARGS
	STATUS=$?
done
exit $STATUS
