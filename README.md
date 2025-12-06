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
Currently, configuration files are loaded from the `assets/` directory:
```
assets/waybox.xml
assets/options.conf
```
A future update will move configuration to `~/.config/waybox/` for user editing.

## Usage
_TBA_

## Screenshots
_TBA_

## License
This project is licensed under the MIT License. See the `LICENSE` file for details.