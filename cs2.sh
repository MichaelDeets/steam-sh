#!/bin/sh -a

# Wine initial configuration
WINEARCH="win64"
WINEDEBUG="-all"
WINEESYNC=0
WINEFSYNC=0
WINESYNC=1

# Locally extracted WINE
#WINE_ROOT=/home/michael/Games/steam/wine/wineroot
WINE_ROOT=/etc/eselect/wine/
WINE=$WINE_ROOT/bin/wine
WINESERVER=$WINE_ROOT/bin/wineserver
WINEPREFIX=/home/michael/Games/steam/wine/prefix

# Steam setup
STEAM_ROOT=/home/michael/Games/steam/steamroot/
STEAM_EXE=$STEAM_ROOT/steam.exe
STEAM_ARGS="-cef-disable-sandbox -cef-disable-seccomp-sandbox -cef-single-process -no-cef-sandbox -nocrashmonitor -nointro -novid -nojoy -no-browser -no-dwrite -cef-disable-gpu -nointro -rememberpassword -single_core"
DXVK_CONFIG_FILE="/home/michael/.config/dxvk/dxvk.conf"
VKBASALT_LOG_LEVEL="none"

# AMD driver config
#VK_ICD_FILENAMES="/usr/share/vulkan/icd.d/amd_pro_icd32.json:/usr/share/vulkan/icd.d/amd_pro_icd64.json"
VK_ICD_FILENAMES="/etc/vulkan/icd.d/amd_icd32.json:/etc/vulkan/icd.d/amd_icd64.json"
AMD_VULKAN_ICD=AMDVLK

if [ ! -d $WINEPREFIX ]; then
	echo "--- Creating WINE prefix ---"
	mkdir -p /home/michael/Games/steam/wine
	wineboot && wineserver
	winetricks msls31 riched20 andale arial comicsans impact tahoma times allfonts d3dcompiler_43 d3dcompiler_47 fontsmooth=rgb 
fi

if [ ! -L $WINEPREFIX/drive_c/windows/system32/d3d11.dll ]; then
	echo "--- Installing DXVK ---"
	WINE=${WINE} WINEPREFIX=${WINEPREFIX} /usr/bin/setup_dxvk.sh install --symlink
fi

echo "--- Launching Steam ---"
. /home/michael/.cs2/pre.sh

STATUS=42
cd $STEAM_ROOT
while [ $STATUS -eq 42 ]; do
	$WINE $STEAM_EXE $STEAM_ARGS
	STATUS=$?
done

. /home/michael/.cs2/post.sh
exit $STATUS
