#!/usr/bin/env bash



FLAG_FILE="/tmp/battery_low.flag"
PREV_STATUS_FILE="/tmp/battery_prev_status.flag" # New file for previous status
LOW_BATTERY_THRESHOLD=15
SESSION_TYPE="$XDG_SESSION_TYPE"
DISCHARGED_COLOR="#D35F5D" # Reverted to original reddish for discharged/low battery
CHARGED_COLOR="#008000"   # Reverted to original greenish for charged/normal battery

has_battery() {
    local battery_path=$(upower -e | grep 'BAT')
    [ -z "$battery_path" ] && return 1 || return 0
}

get_battery_charge() {
    upower -i $(upower -e | grep 'BAT') | grep percentage | awk '{print $2}' | sed s/%//
}

is_charging() {
    upower -i $(upower -e | grep 'BAT') | grep state | awk '{print $2}'
}

notify_battery_time() {
    local remaining_time=$(upower -i $(upower -e | grep 'BAT') | grep --color=never -E "time to empty|time to full" | awk '{print $4, $5}')
    if [ -z "$remaining_time" ] || [[ "$remaining_time" == *"0"* ]]; then
        notify-send "Battery Status" "Remaining time: data is being calculated or unavailable."
    else
        notify-send "Battery Status" "Remaining time: $remaining_time"
    fi
}

print_status() {
    local charge=$(get_battery_charge)
    local charging_status=$(is_charging)
    local icon=""
    local color=""
    if [ "$charging_status" == "charging" ]; then
        case $charge in
            100|9[0-9]) icon="󰂅 " ;;
            8[0-9]) icon="󰂋 " ;;
            7[0-9]) icon="󰂊 " ;;
            6[0-9]) icon="󰢞 " ;;
            5[0-9]) icon="󰢝 " ;;
            4[0-9]) icon="󰂈 " ;;
            3[0-9]) icon="󰂇 " ;;
            2[0-9]) icon="󰂆 " ;;
            1[5-9]) icon="󰢜 " ;;
            *) icon="󰢟 " ;;
        esac
        color=$CHARGED_COLOR
    elif [ "$charging_status" == "fully-charged" ]; then
        icon="󰁹 "
        color=$CHARGED_COLOR
    else
        if [ "$charge" -le "$LOW_BATTERY_THRESHOLD" ]; then
            color=$DISCHARGED_COLOR
        else
            color=$CHARGED_COLOR
        fi
        case $charge in
            100|9[0-9]) icon="󰁹 " ;;
            8[0-9]) icon="󰂂 " ;;
            7[0-9]) icon="󰂁 " ;;
            6[0-9]) icon="󰂀 " ;;
            5[0-9]) icon="󰁿 " ;;
            4[0-9]) icon="󰁾 " ;;
            3[0-9]) icon="󰁽 " ;;
            2[0-9]) icon="󰁼 " ;;
            1[5-9]) icon="󰁺 " ;;
            *) icon="󰂎 " ;;
        esac
    fi

    if [[ "$SESSION_TYPE" == "wayland" ]]; then
        echo "<span color=\"$color\">$icon$charge%</span>"
    elif [[ "$SESSION_TYPE" == "x11" ]]; then
        echo "%{F$color}$icon$charge%%{F-}"
    fi
}

main() {
    local status_mode=false
    local notify_mode=false
    
    while [[ "$#" -gt 0 ]]; do
        case "$1" in
            --status)
                status_mode=true
                shift
                ;;
            --notify)
                notify_mode=true
                shift
                ;;
            --charged-color)
                CHARGED_COLOR="$2"
                shift 2
                ;;
            --discharged-color)
                DISCHARGED_COLOR="$2"
                shift 2
                ;;
            *)
                echo "Invalid option: $1"
                exit 1
                ;;
        esac
    done

    # Get current battery charge and status
    BATTERY_CHARGE=$(get_battery_charge)
    CHARGING_STATUS=$(is_charging) # e.g., "charging", "discharging", "fully-charged"

    # Read previous status
    
    # Read previous status
    local PREV_CHARGING_STATUS="unknown"
    if [ -f "$PREV_STATUS_FILE" ]; then
        PREV_CHARGING_STATUS=$(cat "$PREV_STATUS_FILE")
    fi

    # --- Charging/Discharging Change Notifications ---
    if [ "$CHARGING_STATUS" != "$PREV_CHARGING_STATUS" ]; then
        if [ "$CHARGING_STATUS" == "charging" ]; then
            # Concise: "Charging" title, icon + percentage in body
            notify-send "Battery Charging" "⚡️ ${BATTERY_CHARGE}%" -u low
        elif [ "$CHARGING_STATUS" == "discharging" ]; then
            if [ "$PREV_CHARGING_STATUS" == "charging" ] || [ "$PREV_CHARGING_STATUS" == "fully-charged" ]; then
                # Concise: "Discharging" title, icon + percentage in body
                notify-send "Battery Discharging" "🔌 ${BATTERY_CHARGE}%" -u low
            fi
        elif [ "$CHARGING_STATUS" == "fully-charged" ]; then
            if [ "$PREV_CHARGING_STATUS" == "charging" ]; then
                # Concise: "Battery Full" title, icon + 100% with short action
                notify-send "Battery Full" "✅ 100% (Unplug!)" -u normal
            fi
        fi
    fi # Save current status for next run
    echo "$CHARGING_STATUS" > "$PREV_STATUS_FILE"

    # --- Low Battery Warning Logic ---
    # If started charging, remove low battery flag
    if [ "$CHARGING_STATUS" == "charging" ] && [ -f "$FLAG_FILE" ]; then
        rm "$FLAG_FILE"
    fi
    
    # Send low battery notification
    if [ "$BATTERY_CHARGE" -le "$LOW_BATTERY_THRESHOLD" ]; then
        if [ ! -f "$FLAG_FILE" ] && [ "$CHARGING_STATUS" != "charging" ]; then
            notify-send "Low battery charge" "The battery charge level is $BATTERY_CHARGE%, connect the charger." -u critical
            touch "$FLAG_FILE"
        fi
    elif [ "$BATTERY_CHARGE" -gt "$LOW_BATTERY_THRESHOLD" ]; then
        if [ -f "$FLAG_FILE" ]; then
            rm "$FLAG_FILE"
        fi
    fi
    # --- End Low Battery Warning Logic ---


    # --- Print Status (if --status option is used) ---
    if [[ $status_mode == true ]]; then
        print_status
    fi

    # --- Notify Battery Time (if --notify option is used) ---
    if [[ $notify_mode == true ]]; then
        notify_battery_time
    fi

}


if has_battery; then
    main "$@"
fi