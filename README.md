# loq(uacious)

## speech-to-text hotkey script

`loq` is a single script that provides an easy way to transcribe your speech to text using the OpenAI Whisper API. The script is designed to be bound to a hotkey in a Linux desktop environment but should work on macOS or the Windows Linux Subsystem as well.

## Setup Instructions:

1. **Clone this repository** to your desired location:
    ```bash
    git clone https://github.com/ekg/loq.git
    cd loq
    ```

2. **Set up your configuration file**:
    ```bash
    mkdir -p ~/.loq
    cp loq.keys ~/.loq/keys
    chmod 600 ~/.loq/keys
    ```
    Then edit `~/.loq/keys` and:
    - Choose your preferred API provider (OpenAI or Groq)
    - Uncomment that section
    - Replace the placeholder API key with your actual key
    
    The template includes configurations for both OpenAI and Groq APIs - just uncomment and configure your preferred service.

3. **Install the required dependencies**:
    - `sox` (`rec`): for audio recording
    - `lame`: for MP3 conversion
    - `curl`: for making HTTP requests
    - `xclip`: for clipboard manipulation
    - `xdotool`: for simulating keyboard input (fallback method)
    - `notify-send` and `gdbus`: for notifications
    - `ffprobe`: for audio file analysis (part of ffmpeg)
    - `bc`: for floating point calculations
    - `python3-gi` and `gir1.2-atspi-2.0`: for accessibility interface

    On Ubuntu/Debian systems, you can install all dependencies with:
    ```bash
    sudo apt install sox lame curl xclip xdotool libnotify-bin ffmpeg bc python3-gi gir1.2-atspi-2.0
    ```

    On other Linux distributions, use your package manager to install equivalent packages.

4. **Set up key bindings** in your settings (e.g., keyboard settings on Ubuntu GNOME Shell) to run the `loq` script with the `toggle` subcommand when a particular key or key combination is pressed (e.g., F10).

5. **Move the script to a directory in your PATH** (optional):
    ```bash
    sudo mv loq /usr/local/bin/
    ```

## Usage:

1. **Start or stop recording**: Press your hotkey (e.g., F10) to toggle recording your speech.
2. **Transcription process**: When you stop the recording, the transcription process will be triggered automatically.
3. **Clipboard**: The transcribed text will be automatically copied to your clipboard.
4. **Paste**: Paste the transcribed text into your desired application by using the appropriate keyboard shortcut (e.g., Ctrl+V).

### Directory Structure:
- `~/.loq/recordings`: Stores the recorded MP3 files, transcripts, and stats.
- `~/.loq/tmp`: Temporary files for ongoing processes.
- `~/.loq/stats.tsv`: Aggregated statistics of all recordings.

## Customization:

You can modify the script to suit your specific needs. For example, you can change the audio recording format, bit rate, or other options in the `rec` command. Additionally, you can customize the keyboard shortcuts or add additional functionality to suit your workflow.

## Troubleshooting:

- If you encounter issues with the clipboard not pasting in GNOME Terminal or other applications, ensure that the necessary permissions are granted for clipboard access. You may also need to adjust the keyboard shortcut settings in your GNOME Shell configuration.
- If the automatic pasting doesn't work in your terminal, you might need to manually paste the transcribed text.

## Problems:

Automatic text insertion uses the Linux accessibility API (AT-SPI) to directly place text at the cursor position. This should work in most GTK and Qt applications that support the accessibility APIs. If insertion fails, the script will fall back to the traditional clipboard paste method using xdotool, but this might not work in some terminals. In such cases, you may need to manually paste the text.

You may need to enable accessibility features in your system settings for AT-SPI to work properly. On Ubuntu, go to Settings → Accessibility → Screen Reader and ensure accessibility services are enabled.

## Contributing:

Contributions are welcome! Please feel free to open issues, submit pull requests, or suggest improvements to make `loq` even better.

Happy speaking and typing!

## Note:

- The notifications are currently compatible with Ubuntu. If you are using a different Linux distribution or desktop environment, you may need to modify the script to disable notifications or use another notification system. Patches are very much welcome.

## Example Hotkey Setup:

To set up the hotkey, you will need to provide the full path to the `loq` script. For example, if you moved the script to `/usr/local/bin/`, you would set the hotkey command to:

```bash
/usr/local/bin/loq toggle
```

You'll run this a lot, so it makes sense to avoid complex key combinations. Rarely-used function keys accessible with your dominant index finger, like F8, F9, and F10 are often a good choice.

### Set up hotkey from the command line

On Ubuntu 24.04, hotkeys can be set up by going to Settings, Keyboard, Keyboard Shortcuts: View and Customize Shortcuts, Custom Shortcuts.

But that's annoying. Here's how to set up F9 as your hotkey from the command line:

```bash
export LOQ_PATH='/usr/local/bin/loq toggle'
export HOTKEY='F9'
gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/loq_toggle/']" \
&& gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/loq_toggle/ name 'loq_toggle' \
&& gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/loq_toggle/ command "$LOQ_PATH" \
&& gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/loq_toggle/ binding "$HOTKEY"
```

And here's how to remove _all_ custom keys. That's probably a bug, but that's what it does. Only run if this is your only custom key:

```bash
gsettings reset org.gnome.settings-daemon.plugins.media-keys custom-keybindings && gsettings reset-recursively org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/loq_toggle/
```
