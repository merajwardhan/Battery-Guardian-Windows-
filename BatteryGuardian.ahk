#Requires AutoHotkey v2
#SingleInstance Force

; -------------------- USER CONFIG --------------------
; Ensure this path points directly to your sound file.
SoundPath      := "C:\Users\patil\Downloads\Battery Sounds\battery.wav"

CheckInterval  := 10000   ; How often to check the battery (in milliseconds). 10000 = 10 seconds.
AlertTimeout   := 60000   ; How long the alarm should sound before stopping automatically (in milliseconds). 60000 = 1 minute.
LowThreshold   := 21      ; Alert when battery is BELOW this percentage.
HighThreshold  := 80      ; Alert when battery is ABOVE this percentage.
SoundAlias     := "BatterySiren" ; An internal name for the sound, does not need to be changed.
; -----------------------------------------------------

; --- Global variables to track the alert state ---
global IsAlerting := false
global AlertType := ""  ; Will be "low" or "high"

; --- GUI Definition (the window that appears during an alert) ---
AlertGui := Gui("+AlwaysOnTop -MinimizeBox -MaximizeBox", "Battery Alert")
; ** THE FIX IS HERE: ** Create the text control and save it to the AlertGuiText variable.
global AlertGuiText := AlertGui.Add("Text", "w220 Center", "")
StopButton := AlertGui.Add("Button", "w120 Center Default", "Stop Sound")
StopButton.OnEvent("Click", StopAlert) ; When the button is clicked, it calls the StopAlert function.
AlertGui.Hide() ; The GUI is hidden until an alert is triggered.

; --- Start monitoring ---
SetTimer(CheckBattery, CheckInterval)
CheckBattery()  ; Run the check once immediately when the script starts.
return

/**
 * Checks the battery's charge level and power connection status.
 */
CheckBattery(*)
{
    local chargePercent, isPluggedIn

    try {
        battery := ComObjGet("winmgmts:").ExecQuery("SELECT * FROM Win32_Battery").ItemIndex(0)
        if !IsObject(battery) {
            ExitApp  ; Exit the script if no battery is detected.
        }
        chargePercent := battery.EstimatedChargeRemaining
        isPluggedIn := (battery.BatteryStatus != 1) ; 1 means 'Discharging'. Any other status means it is charging or full.
    } catch {
        ToolTip("Error: Could not check battery status.")
        return
    }

    ; --- Logic to decide when to start or stop an alert ---
    shouldAlertLow := (chargePercent < LowThreshold and !isPluggedIn)
    shouldAlertHigh := (chargePercent > HighThreshold and isPluggedIn)

    if (IsAlerting) {
        ; If the alarm is already on, check if the condition has been resolved.
        if (AlertType = "low" and !shouldAlertLow) {
            StopAlert()
        } else if (AlertType = "high" and !shouldAlertHigh) {
            StopAlert()
        }
    } else {
        ; If the alarm is off, check if a new alert needs to be started.
        if (shouldAlertLow) {
            StartAlert("low")
        } else if (shouldAlertHigh) {
            StartAlert("high")
        }
    }
}

/**
 * Starts the alert: shows the GUI, plays the sound, and sets the auto-stop timer.
 * @param type "low" or "high" to indicate the alert reason.
 */
StartAlert(type)
{
    if (IsAlerting)  ; Prevent starting a new alert if one is already running.
        return

    global IsAlerting := true
    global AlertType := type

    ; Update the GUI text based on the alert type and show the window.
    AlertGuiText.Value := (type = "low")
        ? "Battery is low! Please plug in the charger."
        : "Battery is high! Please unplug the charger."
    AlertGui.Show()

    ; Play the sound file once.
    PlayAlertSound()

    ; Set a timer to automatically stop the alert after the configured timeout.
    SetTimer(StopAlert, -AlertTimeout)
}

/**
 * Stops the alert: stops the sound, hides the GUI, and cancels timers.
 */
StopAlert(*)
{
    if (!IsAlerting) ; Do nothing if the alert is already off.
        return

    global IsAlerting := false
    global AlertType := ""

    ; Immediately stop the sound that is playing.
    StopAlertSound()

    ; Hide the GUI window.
    AlertGui.Hide()

    ; Cancel the automatic stop timer so it doesn't run unexpectedly.
    SetTimer(StopAlert, 0)
}

/**
 * Uses the Media Control Interface (MCI) to play the sound file.
 * This method allows the sound to be stopped forcefully.
 */
PlayAlertSound()
{
    global SoundPath, SoundAlias
    ; This command string is built carefully to include quotes around the file path.
    command := "Open " . Chr(34) . SoundPath . Chr(34) . " Alias " . SoundAlias

    DllCall("winmm\mciSendString", "Str", "Close " . SoundAlias, "Ptr", 0, "Int", 0, "Ptr", 0)
    DllCall("winmm\mciSendString", "Str", command, "Ptr", 0, "Int", 0, "Ptr", 0)
    DllCall("winmm\mciSendString", "Str", "Play " . SoundAlias, "Ptr", 0, "Int", 0, "Ptr", 0)
}

/**
 * Uses MCI to immediately stop the sound file.
 */
StopAlertSound()
{
    global SoundAlias
    DllCall("winmm\mciSendString", "Str", "Stop " . SoundAlias, "Ptr", 0, "Int", 0, "Ptr", 0)
    DllCall("winmm\mciSendString", "Str", "Close " . SoundAlias, "Ptr", 0, "Int", 0, "Ptr", 0)
}
