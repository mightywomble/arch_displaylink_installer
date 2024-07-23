#!/bin/bash

# Check if the script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

WORKINGDIR="$HOME/Downloads/displaylink"
DLFILE="displaylink.tar.gz"
EVDIFILE="evdi.tar.gz"

download_and_extract() {
    local file=$1
    wget "https://aur.archlinux.org/cgit/aur.git/snapshot/$file" -P "$WORKINGDIR" || exit 1
    tar xzvf "$WORKINGDIR/$file" -C "$WORKINGDIR" || exit 1
    (cd "$WORKINGDIR" && makepkg -si) || exit 1
}

# Install necessary packages
pacman -S --needed base-devel || exit 1
pacman -S core/linux-headers || exit 1

# Create working directory
mkdir -p "$WORKINGDIR" || exit 1

# Download and install EVDI and DisplayLink
download_and_extract "$EVDIFILE"
download_and_extract "$DLFILE"

# Load the udl module and start the DisplayLink service
modprobe udl || exit 1
systemctl start displaylink.service || exit 1
