# -*- coding: utf-8 -*-
import logging
import asyncio
import os
from bleak import BleakClient
import paho.mqtt.client as mqtt
import json

# Configure logging to output to stdout
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

# Renogy BMS Bluetooth UUIDs (example - adjust based on your device)
RENOGY_SERVICE_UUID = "0000fff0-0000-1000-8000-00805f9b34fb"
RENOGY_CHAR_UUID = "0000fff1-0000-1000-8000-00805f9b34fb"

async def connect_to_renogy(mac_address):
    logger.info(f"Connecting to Renogy device at {mac_address}...")
    try:
        client = BleakClient(mac_address)
        await client.connect()
        logger.info("Successfully connected to Renogy device")
        return client
    except Exception as e:
        logger.error(f"Failed to connect: {e}")
        return None

def on_connect(client, userdata, flags, rc):
    logger.info("Connected to MQTT broker")
    client.subscribe("renogy/#")  # Subscribe to any Renogy-related topics

def on_message(client, userdata, msg):
    logger.info(f"Received MQTT message: {msg.topic} - {msg.payload.decode()}")

async def read_renogy_data(client):
    try:
        # Read data from the Renogy BMS (example - adjust based on your device's protocol)
        value = await client.read_gatt_char(RENOGY_CHAR_UUID)
        logger.info(f"Raw data from Renogy: {value.hex()}")
        return value
    except Exception as e:
        logger.error(f"Error reading Renogy data: {e}")
        return None

async def publish_to_mqtt(mqtt_client, topic, data):
    try:
        mqtt_client.publish(topic, json.dumps(data))
        logger.info(f"Published to MQTT: {topic} - {data}")
    except Exception as e:
        logger.error(f"Failed to publish to MQTT: {e}")

async def main():
    logger.info("Starting Renogy Bluetooth Monitor...")
    
    # Get configuration from environment variables
    device_mac = os.environ.get("DEVICE_MAC", "")
    device_alias = os.environ.get("DEVICE_ALIAS", "renogy_battery")
    mqtt_host = os.environ.get("MQTT_HOST", "core-mosquitto")
    mqtt_port = int(os.environ.get("MQTT_PORT", "1883"))
    mqtt_username = os.environ.get("MQTT_USERNAME", "")
    mqtt_password = os.environ.get("MQTT_PASSWORD", "")

    if not device_mac:
        logger.error("Device MAC address not configured. Please set DEVICE_MAC environment variable.")
        return

    # Connect to Renogy device
    renogy_client = await connect_to_renogy(device_mac)
    if not renogy_client:
        logger.error("Could not start monitoring - Renogy connection failed")
        return

    # Set up MQTT client
    mqtt_client = mqtt.Client()
    if mqtt_username and mqtt_password:
        mqtt_client.username_pw_set(mqtt_username, mqtt_password)
    mqtt_client.on_connect = on_connect
    mqtt_client.on_message = on_message
    mqtt_client.connect(mqtt_host, mqtt_port, keepalive=60)

    try:
        while True:
            # Read data from Renogy BMS
            data = await read_renogy_data(renogy_client)
            if data:
                # Parse and publish data (example - adjust based on your needs)
                parsed_data = {"voltage": data.hex()[:4], "current": data.hex()[4:8]}  # Placeholder parsing
                topic = f"renogy/{device_alias}/status" if device_alias else f"renogy/{device_mac}/status"
                await publish_to_mqtt(mqtt_client, topic, parsed_data)
            await asyncio.sleep(10)  # Poll every 10 seconds
    except Exception as e:
        logger.error(f"Monitoring loop failed: {e}")
    finally:
        if renogy_client:
            await renogy_client.disconnect()
        mqtt_client.disconnect()

if __name__ == "__main__":
    asyncio.run(main())