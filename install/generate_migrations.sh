#!/usr/bin/env bash

VIBRANIUM="$HOME/.local/share/vibranium"
STATE_DIR="$HOME/.local/state/vibranium/migrations"
MIGRATIONS_DIR="$VIBRANIUM/migrations"

mkdir -p "$STATE_DIR"

for file in "$MIGRATIONS_DIR"/*.sh; do
    touch "$STATE_DIR/$(basename "$file")"
done
