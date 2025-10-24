#!/usr/bin/env bash

case "$(</sys/class/dmi/id/chassis_type)" in
    9|10|14)  # Laptop, Notebook, Sub-Notebook
        LOCK_AFTER=120
		SLEEP_AFTER=600
        ;;
    *)  # Desktop / Other
        LOCK_AFTER=600
		SLEEP_AFTER=900
        ;;
esa

cat << EOF > "$HOME/.config/hypr/hypridle.conf"
source = ~/.local/share/vibranium/defaults/hypr/hypridle.conf

listener {
	timeout = $LOCK_AFTER
	on-timeout = loginctl lock-session
}

listener {
	timeout = $SLEEP_AFTER
	on-timeout = systemctl suspend
}

# vim:ft=hyprlang
EOF
