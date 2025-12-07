# waybox


## Description
Waybox is a minimal, configurable launcher menu designed to be triggered from Waybar or any external command.

It reads a simple XML configuration file and displays a clean, single-level menu where each item launches an application or command.

## Features
- Configurable single-level menu via `waybox.xml`.
- Customizable colors, window size and coordinates via `options.conf`.
- Launch applications using plain Bash commands.
- Automatic closing when the mouse leaves the window.
- Designed for Wayland + Waybar workflows.

## Requirements
- Flutter 3.35.7 or later (stable)
- Linux (Wayland recommended)

## Installation
Clone the repository and run waybox:
```bash
git clone https://github.com/ifgar/waybox.git
cd waybox
flutter pub get
flutter run
```

## Configuration
Waybox stores user-editable configuration files in:
```
~/.config/waybox/
```
Two files control the entire behavior:
- **waybox.xml** — defines the menu items  
- **options.conf** — defines window size, position and colors

These files are automatically created on first launch if missing.  
You can edit them at any time without rebuilding the app.

## Usage

Waybox is typically launched from Waybar or any scriptable launcher.

### Example Waybar module
```json
  "custom/waybox": {
    "format": "",
    "on-click": "waybox",
    "tooltip": false
  },
```

### Launch manually
```bash
waybox
```

### Edit configuration
```bash
nano ~/.config/waybox/waybox.xml
nano ~/.config/waybox/options.conf
```

Waybox reloads its configuration on every launch.

## Example configuration

### `waybox.xml`
```xml
<waybox>
  <menu name="Terminal" command="alacritty" />
  <menu name="Files" command="thunar" />
  <menu name="Reboot" command="systemctl reboot" />
</waybox>
```

### `options.conf`
```ini
[size]
width=300
height=220
x=100
y=100

[theme]
text=#FFFFFF
hover=#222222
background=#000000
```


## Screenshots
_TBA_

## License
This project is licensed under the MIT License. See the `LICENSE` file for details.