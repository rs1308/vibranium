#!/usr/bin/env bash

set -euo pipefail


LOOKNFEEL_CONF="$HOME/.config/hypr/hyprland.conf.d/look-and-feel.conf"
LOOKNFEEL_OPTS=(
	"animations:enabled:true"
	"decoration:dim_inactive:true"
	"decoration:rounding:0"
	"decoration:blur:enabled:false"
	"decoration:blur:size:5"
	"decoration:shadow:enabled:true"
)

RED=$'\e[0;31m'
YELLOW=$'\e[0;33m'
GREEN=$'\e[0;32m'
GRAY=$'\e[90m'
RESET=$'\e[0m'

export SUDO_PROMPT; SUDO_PROMPT="$(printf '\n%s[VIBRANIUM]%s Password for %s: ' "$RED" "$RESET" "$USER")"

if [[ "$(id -u)" == 0 ]]; then
	echo "${RED}[ERROR]${RESET} Do not run this as root!"
	exit 1
fi

if ! command -v yay >/dev/null; then
	printf "%s[VIBRANIUM]%s Installing %syay%s" "${YELLOW}" "${RESET}" "${GRAY}" "${RESET}"
	if ! command -v git >/dev/null; then
		sudo pacman -S git --noconfirm
	fi

	CWD="$(pwd)"
	cd "$(mktemp -d)" || exit
	git clone -q https://aur.archlinux.org/yay
	cd yay || exit
	makepkg -sirc --noconfirm &> /dev/null
	cd "$CWD" || exit
fi

# Hide cursor
printf '\e[?25l'

cleanup() {
	yay -Ycc --noconfirm &>/dev/null
	sudo pacman -Scc --noconfirm &>/dev/null
}

install_packages() {
	local packages pkg start_time elapsed pid aur_flag

	mapfile -t packages < ./pkg_list.txt

	if [ -n "$(find /sys/class/backlight -mindepth 1 -maxdepth 1 2>/dev/null)" ]; then
		packages+=("brightnessctl")
	fi

	# GPU detection
	case "$(lspci | grep VGA)" in
		*Radeon*|*ATI*)
			printf "%s[VIBRANIUM]%s Detected AMD GPU - adding drivers to install queue\n" "$YELLOW" "$RESET"
			packages+=(
				"mesa"
				"lib32-mesa"
				"rocm-smi-lib"
				"vulkan-radeon"
				"lib32-vulkan-radeon"
				"libvdpau-va-gl"
			)
			;;
		*UHD*|*Iris*|*Arc*)
			printf "%s[VIBRANIUM]%s Detected Intel GPU - adding drivers to install queue\n" "$YELLOW" "$RESET"
			packages+=(
				"mesa"
				"lib32-mesa"
				"libvpl"
				"vulkan-intel"
				"lib32-vulkan-intel"
				"libvdpau-va-gl"
				"vpl-gpu-rt"
			)
			;;
	esac

	mapfile -t packages < <(printf "%s\n" "${packages[@]}" | sort -u)

	for pkg in "${packages[@]}"; do
		[[ -z "${pkg//[[:space:]]/}" ]] && continue
		[[ "${pkg:0:1}" == "#" ]] && continue

		if ! pacman -Si "$pkg" >/dev/null 2>&1; then
			aur_flag=" (AUR, may take longer time to install)"
		else
			aur_flag=""
		fi

		printf "\r\033[K%s[VIBRANIUM]%s Installing %s%s%s " \
			"$YELLOW" "$RESET" "$GRAY" "$pkg" "$aur_flag"

		start_time=$(date +%s)

		if [ "$pkg" == "pipewire-jack" ]; then
			if pacman -Qq jack2 &>/dev/null; then
				sudo pacman -Rdd jack2 --noconfirm &>/dev/null
			fi
		fi

		yay -S --noconfirm --needed "$pkg" &>/dev/null
		pid=$!

		while kill -0 "$pid" 2>/dev/null; do
			sudo -v; sleep 1
			elapsed=$(( $(date +%s) - start_time ))
			if (( elapsed > 10 )); then
				printf "\r\033[K%s[VIBRANIUM]%s Installing %s%s [%ds] %s" \
					"$YELLOW" "$RESET" "$GRAY" "$pkg$aur_flag" "$elapsed" "$RESET"
			fi
		done

		wait "$pid"
	done

	printf "\r\033[K%s[VIBRANIUM]%s Packages installed\n" "$YELLOW" "$RESET"
}

enable_system_services() {
	local system_services
	local user_services

	system_services=(
		"ly"
		"power-profiles-daemon"
		"bluetooth"
	)

	user_services=(
		"waybar"
		"swayosd"
		"cliphist"
		"hypridle"
		"hyprpaper"
		"hyprsunset"
		"gnome-polkit"
	)

	for service in "${system_services[@]}"; do
		sudo systemctl -q enable "$service"
	done

	for service in "${user_services[@]}"; do
		systemctl -q --user enable "$service"
	done
}

create_directories() {
	mkdir -p \
		"${HOME}"/.config/{Vencord,vesktop}/{themes,settings} \
		"$HOME"/.config/heroic/{themes,store} \
		"$HOME/.config/spicetify/Themes/text" \
		"$HOME/.config/hypr/hyprland.conf.d" \
		"$HOME/.local/share/applications" \
		"$HOME/.local/state/vibranium/" \
		"$HOME/.config/vibranium/theme" \
		"$HOME/.config/qt6ct/colors" \
		"$HOME/.config/btop/themes/" \
		"$HOME/.config/wlogout" \
		"$HOME/.config/gtk-3.0" \
		"$HOME/.config/gtk-4.0" \
		"$HOME/.config/zathura" \
		"$HOME/.config/swayosd" \
		"$HOME/.config/dunst" \
		"$HOME/.config/uwsm" \
		"$HOME/.config/imv"
}

post_install() {
	touch "$HOME/.local/state/vibranium/first-boot"
	echo "suspended" > \
		"$HOME/.local/state/vibranium/night-light"
}

sudo -v; clear
# Move VT to the bottom
printf '\e[2J\e[%d;1H' "${LINES:-$(tput lines)}"
cat ./logo.txt

printf "%s[VIBRANIUM]%s Setting up system files\n" "${YELLOW}" "${RESET}"
./install/edit_system_files.sh

printf "%s[VIBRANIUM]%s Refreshing repositories\n" "${YELLOW}" "${RESET}"
sudo pacman -Suy --noconfirm &>/dev/null

install_packages
create_directories

./install/install_gtk_themes.sh
./install/install_papirus_icons.sh
./install/install_local_bin.sh

printf "\n%s[VIBRANIUM]%s Setting up config files" "${YELLOW}" "${RESET}"

ln -sf "$(realpath ./applications/custom)" "$HOME"/.local/share/applications/ >/dev/null
for entry in ./applications/*.desktop ./applications/hidden/*; do
    ln -sf "$(realpath "$entry")" "$HOME/.local/share/applications/" >/dev/null
done

for opt in "${LOOKNFEEL_OPTS[@]}"; do
	./bin/vibranium-cmd-edit-wm-config "$opt" "$LOOKNFEEL_CONF"
done

for file in ./install/generate_*; do
	bash "$file"
done

printf "\n%s[VIBRANIUM]%s Setting default theme" "${YELLOW}" "${RESET}"
./install/set_default_theme.sh

printf "\n%s[VIBRANIUM]%s Installing systemd services" "${YELLOW}" "${RESET}"
enable_system_services
post_install
cleanup

printf "\n%s[VIBRANIUM]%s Installation complete%s" "${YELLOW}" "${GREEN}" "${RESET}"
printf "\n%s[VIBRANIUM]%s Reboot your PC to start using Vibranium\n" "${YELLOW}" "${RESET}"

printf '\e[?25h'  # show cursor
