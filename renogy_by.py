#!/usr/bin/with-contenv bashio

# Load configuration from Home Assistant
MQTT_HOST=$(bashio::config 'mqtt_host')
MQTT_PORT=$(bashio::config 'mqtt_port')
MQTT_USERNAME=$(bashio::config 'mqtt_username')
MQTT_PASSWORD=$(bashio::config 'mqtt_password')
DEVICES=$(bashio::config 'devices')

# Run the Python script
python3 /renogy_bt.py \
  --mqtt_host "$MQTT_HOST" \
  --mqtt_port "$MQTT_PORT" \
  --mqtt_username "$MQTT_USERNAME" \
  --mqtt_password "$MQTT_PASSWORD" \
  --devices "$DEVICES"
