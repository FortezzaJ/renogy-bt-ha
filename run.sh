#!/usr/bin/with-contenv bashio

# Load configuration from Home Assistant
DEVICE_MAC=$(bashio::config 'device_mac')
DEVICE_ALIAS=$(bashio::config 'device_alias')
MQTT_HOST=$(bashio::config 'mqtt_host')
MQTT_PORT=$(bashio::config 'mqtt_port')
MQTT_USERNAME=$(bashio::config 'mqtt_username')
MQTT_PASSWORD=$(bashio::config 'mqtt_password')

# Set environment variables for the Python script
export DEVICE_MAC="${DEVICE_MAC}"
export DEVICE_ALIAS="${DEVICE_ALIAS}"
export MQTT_HOST="${MQTT_HOST:-core-mosquitto}"
export MQTT_PORT="${MQTT_PORT:-1883}"
export MQTT_USERNAME="${MQTT_USERNAME:-}"
export MQTT_PASSWORD="${MQTT_PASSWORD:-}"

# Run the Python script and pipe output to stdout for logging
exec python3 /renogy_bt.py
