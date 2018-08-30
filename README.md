# Hotkeys Plugin

A plugin for adding hotkeys to improve productivity

## Features
- Keyboard
	- Menu
		- Ctrl+Z => Undo
		- Ctrl+C => Copy
		- Ctrl+X => Cut
		- Ctrl+V => Paste

	- Toolbar
		- E => Edit Contour
		- Alt+D(Hold) => Data Cursor
		- Plus => Zoom In
		- Minus => Zoom Out
		- Alt+P(Hold) => Pan
		- Alt+C(Hold) => Adjust Contrast
		- Alt+R(Hold) => 3d Rotation

	- Viewer
		- Numpad Number => Switch Slice
		- Number => Switch Roi
		- `(~) => No Roi
		- Right Arrow/A => Next Phase
		- Left Arrow/D => Previous Phase
		- Up Arrow/W => Previous Tab
		- Down Arrow/S => Next Tab
		- Tab => Switch Tab/Viewer
		- Space => Playback

- Mouse
	- Left Click => Drag Points on a Contour
	- Middle Click => Drag Contours
	- Right Click => Context Menu/Confirm
			
## Installation
After installation of *DENSEanalysis*, run the following from the MATLAB command line:

```matlab
plugins.PluginManager.import('https://github.com/MMoTH/Hotkeys_plugin')
```

## Credits
* This package was created using the windowkeypress function written by Dr. Jonathan Suever as a template.

## Known Bugs

## Known Issues
1.Error in plugins.PluginMenu/checkAvailability

Temperal Solution: Disable checkAvailability
