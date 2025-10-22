# Vibranium

Vibranium is an Arch Linux configuration focused on speed and high customizability.
Thanks to the Hyprland window manager, Waybar bar, and highly customizable rofi launcher, Vibranium provides a beautiful overall look right out of the box.

## Installation

It is recommended to install Vibranium on a clean Arch Linux installation (e.g. immediately after `archinstall`). Installation on existing systems has not been tested and is not recommended.

The installer will automatically find the correct GPU drivers and install them. Since I don't have an Nvidia GPU, there is no support at this time. PRs are welcome.
Ensure you have an active internet connection and that git is installed.
To install Vibranium, type the code below in TTY:

```bash
mkdir -p "$HOME/.local/share"; cd "$HOME/.local/share"
git clone https://github.com/shvedes/vibranium; cd vibranium
./install.sh
```

## Currenet State

Vibranium is currently in alpha testing. Some features may break or not work at all. Breaking changes may occur at any time. If you want to install Vibranium for testing purposes, it is best to do so in a virtual machine. In this case, some functionality will be unavailable. 
