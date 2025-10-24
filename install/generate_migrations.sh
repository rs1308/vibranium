#!/usr/bin/env bash

STATE_DIR="$HOME/.local/state/vibranium/migrations"
mkdir -p "$STATE_DIR"

for file in ./migrations/*.sh; do
	touch "$STATE_DIR/$file"
done
