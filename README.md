# Shelly Pro 4PM Basic UI

This project provides a basic UI for the Shelly Pro 4PM device flashed with Tasmota firmware.

## Installation

To install, you need to upload the `ShellyPro4PM.tapp` Tasmota application file along with the `Display.ini` file to your Tasmota filesystem.
You will need to restart your device for the changes to be applied.

## Compile from Source

If you prefer to compile the application from source, follow these steps:

1. Download the `src` folder from this repository.
2. Use the following command to create the Tasmota application (`.tapp` file):

   ```bash
   rm -f ShellyPro4PM.tapp; zip -j -0 ShellyPro4PM.tapp src/*
After compilation, follow the installation steps above to upload the newly created .tapp file to your device.

