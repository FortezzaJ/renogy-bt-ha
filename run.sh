#!/usr/bin/with-contenv bashio

# Load configuration from Home Assistant
MQTT_HOST=$(bashio::config 'mqtt_host')
MQTT_PORT=$(bashio::config 'mqtt_port')
MQTT_USERNAME=$(bashio::config 'mqtt_username')
MQTT_PASSWORD=$(bashio::config 'mqtt_password')
DEVICES=$(bashio::config 'devices')

# Extract the first device's address from the devices list (assuming it's JSON or a string)
if bashio::var.has_value "${DEVICES}"; then
    DEVICE_ADDRESS=$(echo "${DEVICES}" | jq -r '.[0].address' 2>/dev/null || echo "${DEVICES}" | cut -d',' -f1)
else
    DEVICE_ADDRESS=""
fi

# Set environment variables for the Python script
export DEVICE_ADDRESS="${DEVICE_ADDRESS}"
export MQTT_HOST="${MQTT_HOST:-core-mosquitto}"
export MQTT_PORT="${MQTT_PORT:-1883}"
export MQTT_USERNAME="${MQTT_USERNAME:-}"
export MQTT_PASSWORD="${MQTT_PASSWORD:-}"

# Run the Python script and pipe output to stdout for logging
exec python3 /renogy_bt.py
