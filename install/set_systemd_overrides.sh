#!/bin/bash

SERVICES=("waybar")

for unit in "${SERVICES[@]}"; do
	mkdir -p "$HOME/.config/systemd/user/${unit}.service.d"
done

echo -e "[Unit]\nStartLimitIntervalSec=0" > "$HOME/.config/systemd/user/waybar.service.d/override.conf"
