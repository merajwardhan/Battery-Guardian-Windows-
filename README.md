# Battery-Guardian-Windows-
A autoHotKey script for windows that notifies when the battery is low or charged upto 80% threshold. 

***

# AutoHotkey Battery Alert Script

A simple yet effective AutoHotkey (v2) script that monitors your laptop's battery level and provides audible and visual alerts when the charge is too low or too high. This helps you protect your battery's health by reminding you to plug in or unplug your charger at the right times.

## Features

*   **Low Battery Alert:** Notifies you to connect your charger when the battery drops below a specified level.
*   **High Battery Alert:** Reminds you to unplug the charger when the battery exceeds a certain charge to prevent overcharging.
*   **Customizable Thresholds:** Easily configure the low and high battery percentages to fit your needs.
*   **Custom Alert Sound:** Use any `.wav` sound file for your alerts.
*   **Visual Notification:** A simple window pops up with the alert message and an option to stop the sound.
*   **Configurable Timers:** Adjust how often the script checks the battery status and how long the alert sound plays before stopping automatically.
*   **Intelligent Alerts:** The script is smart enough to only alert you when it's appropriate (e.g., it won't trigger a low battery alert if the charger is already plugged in).

## Prerequisites

To use this script, you must have **AutoHotkey version 2.0** or newer installed on your Windows system. You can download it from the official AutoHotkey website: [https://www.autohotkey.com/](https://www.autohotkey.com/)

## Installation and Usage

Follow these steps to get the script up and running:

1.  **Download the Script:** Save the code as a file with an `.ahk` extension (e.g., `BatteryAlert.ahk`).

2.  **Get an Alert Sound:**
    *   Find a `.wav` sound file you want to use for the alert.
    *   Place it in a permanent location on your computer, for example, in a `C:\MySounds\` directory.

3.  **Configure the Script:**
    *   Open the `BatteryAlert.ahk` file with a text editor (like Notepad or VS Code).
    *   Locate the `USER CONFIG` section at the top of the file.
    *   **Crucially, update the `SoundPath` variable** to point to the exact location of your chosen `.wav` file.
        ```autohotkey
        SoundPath      := "C:\Path\To\Your\Sound\file.wav"
        ```
    *   Adjust the other settings like `LowThreshold` and `HighThreshold` to your preference.

4.  **Run the Script:**
    *   Double-click the `BatteryAlert.ahk` file to run it.
    *   A new AutoHotkey icon will appear in your system tray (usually in the bottom-right corner of your screen). This indicates that the script is running in the background.

5.  **(Optional) Run on Startup:**
    *   To have the script run automatically every time you start your computer, place a shortcut to the script in your Windows Startup folder. You can open this folder by pressing `Win + R`, typing `shell:startup`, and hitting Enter.

## Customization Options

All user-configurable settings are located at the top of the script in the `USER CONFIG` section for easy access.

| Variable | Default Value | Description |
| :--- | :--- | :--- |
| `SoundPath` | `"C:\Users\patil\Downloads\Battery Sounds\battery.wav"` | **(Required)** The full path to the `.wav` sound file you want to use for alerts. |
| `CheckInterval` | `10000` | How often the script checks the battery status, in milliseconds. `10000` equals 10 seconds. |
| `AlertTimeout` | `60000` | The duration for which the alert sound will play before stopping automatically, in milliseconds. `60000` equals 1 minute. |
| `LowThreshold` | `21` | The script will trigger a "low battery" alert when the charge drops **below** this percentage (e.g., at 20%). |
| `HighThreshold` | `80` | The script will trigger a "high battery" alert when the charge goes **above** this percentage (e.g., at 81%). |

## How It Works

The script operates on a simple loop controlled by a timer (`SetTimer`). Here’s a high-level overview of its logic:

1.  **Initialization:** When the script starts, it defines the GUI window for the alert but keeps it hidden. It then starts a recurring timer to call the `CheckBattery` function.
2.  **Battery Check:** At each interval (e.g., every 10 seconds), the `CheckBattery` function queries the Windows Management Instrumentation (WMI) to get the current battery percentage and whether the AC adapter is plugged in.
3.  **Alert Logic:**
    *   It checks if the conditions for a low battery alert are met (percentage is below `LowThreshold` AND the charger is unplugged).
    *   It checks if the conditions for a high battery alert are met (percentage is above `HighThreshold` AND the charger is plugged in).
4.  **Triggering an Alert:** If an alert condition is met and no alert is currently active, the `StartAlert` function is called. This function:
    *   Shows the GUI window with the appropriate message.
    *   Plays the specified sound file.
    *   Sets a one-time timer to automatically stop the alert after the `AlertTimeout` duration.
5.  **Stopping an Alert:** The alert can be stopped in three ways:
    *   The user clicks the "Stop Sound" button on the pop-up window.
    *   The `AlertTimeout` is reached.
    *   A subsequent battery check shows that the condition has been resolved (e.g., the charger was plugged in for a low battery alert).

The `StopAlert` function handles hiding the GUI, stopping the sound, and resetting the script's state so it's ready to alert again.

## Files

*   **`BatteryAlert.ahk` (This Script):** The main and only file required. It contains all the logic for monitoring the battery and triggering alerts.

## Known Issues / Limitations

*   **No Battery Detection:** The script will exit immediately if it cannot detect a battery. This is by design and means it is not suitable for desktop computers.
*   **Sound File Format:** The script is configured for `.wav` files. Other audio formats may not work correctly with the current sound-playing method (MCI).
*   **Single Sound:** The script uses the same sound for both low and high battery alerts.

## How to Contribute

This is a personal script, but improvements and suggestions are always welcome! If you have ideas for new features or find a bug, feel free to fork the repository (if applicable) or just share your modified code. Some ideas for improvement include:
*   Adding separate sounds for low and high alerts.
*   Implementing a "snooze" feature for alerts.
*   Creating a more advanced GUI for configuration instead of editing the script directly.
