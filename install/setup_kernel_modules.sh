#!/usr/bin/env bash

sudo tee /etc/modprobe.d/blacklist.conf >/dev/null <<EOF
# Vibranium: disable hardware watchdog
blacklist sp5100_tco
blacklist iTCO_wdt
EOF

sudo tee /etc/modules-load.d/ntsync.conf >/dev/null <<EOF
# Vibranium: load ntsync driver for better gaming compatibility with Wine.
# More info: https://www.phoronix.com/news/Linux-6.14-NTSYNC-Driver-Ready
ntsync
EOF

