# waybox
Waybox is a minimal, configurable launcher menu designed to be triggered from Waybar or any external command.

It reads a simple XML configuration file and displays a clean, single-level menu where each item launches an application or command.  
Fully self-contained Flutter binary with Wayland layer-shell support.

## Preview
  <img src="screenshots/waybox-demo.gif" width="220">

## Features
- Configurable single-level menu via `waybox.xml`.
- Customizable appearance via `theme.conf`.
- CLI arguments for menu selection and positioning (`--menu`, `--x`, `--y`).
- Launch applications using plain Bash commands.
- Native Wayland layer-shell integration.

## Requirements
- Linux (with Wayland)
- Flutter 3.35.7 or later (stable) only for building from source.

## Installation
### RPM package (recommended)
```bash
sudo dnf install waybox-1.1.0-x86_64.rpm
```

### From source
```bash
git clone https://github.com/ifgar/waybox.git
cd waybox
flutter pub get
flutter build linux --release
./build/linux/x64/release/bundle/waybox
```

### Hyprland note
Hyprland applies animations to layer-shell surfaces by default. If this rule is not added, Waybox will first appear centered on the screen and then slide to the user-defined coordinates, which is undesirable.

To disable this behavior, add the following to your `hyprland.conf`:

```
layerrule = noanim, waybox
```


## Configuration
Waybox stores user-editable configuration files in:
```
~/.config/waybox/
```

These files are automatically created on first launch if missing. 
You can edit them at any time without rebuilding the app.  
`waybox.xml` defines the menu items while `theme.conf` defines window and items appearance.


### Configuration files
#### `waybox.xml`
```xml
<menu name="root">
  <menu name="Calculator" command="gnome-calculator" />
  <menu name="Browser" command="firefox" />
  <menu name="Files" command="thunar" />
</menu>
```

#### `theme.conf`
```ini
[menu]
background= #1F2335
radius= 4

[item]
text= #C0CAF5
hover= #292E42
hoverText= #7DCFFF
```

#### Field reference
- **background**: window background color.
- **radius**: window border radius.
- **text**: item text color.  
- **hover**: item background color while hovering.  
- **hoverText**: item text color while hovering.

#### Notes
- Missing values fall back to internal defaults.  
- Changes apply on the next launch.  
- **Hyprland:** without `layerrule = noanim, waybox` the window will first spawn centered and then “jump” to `(x, y)`, which is undesirable.


## Usage
Waybox is typically launched from Waybar or any scriptable launcher.

### Example Waybar module
```json
  "custom/waybox": {
    "format": "",
    "on-click": "waybox --x 2290 --y 4",
    "tooltip": false
  },
```

Waybox reloads its configuration on every launch.  
`--x` and `--y` define the coordinates in which waybox will appear.

### Multiple instances
You can have as many instances of waybox as you desire. Just specify a different XML file with `--menu`
```json
  "custom/waybox1": {
    "format": "",
    "on-click": "waybox --x 1820 --y 4",
    "tooltip": false
  },

  "custom/waybox2": {
    "format": "",
    "on-click": "waybox --menu waybox2.xml --x 1720 --y 4",
    "tooltip": false
  },
```
Defaults to `waybox.xml` when `--menu` is omitted.


## Screenshot
![waybox screenshot](screenshots/waybox.png)

## License
This project is licensed under the MIT License. See the `LICENSE` file for details.