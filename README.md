# PasteTyper
AutoHotkey and Python scripts that type out the contents of the clipboard using diffing, intended for use with ComputerCraft in Minecraft

## Operating system support
Only Windows is supported, since [AutoHotkey](https://www.autohotkey.com/) is used.

## Release version
Download one of the [releases](https://github.com/sbond75/PasteTyper/releases), extract it, and run the PasteTyper program included.
The releases include a pre-compiled [Paste.ahk](Paste.ahk) as a Windows executable, as well as a Python interpreter and the dependencies it needs.

## Usage
1. Copy text that you want to paste into ComputerCraft or some program that supports similar editing controls (arrow keys to move the cursor, etc.).
2. Press Shift-Alt-p to paste into ComputerCraft or another program. It will type in only the changes since the last paste performed with Shift-Alt-p.

## Advanced usage
- To clear the last saved clipboard contents, press Shift-Alt-i. This will make [Paste.ahk](Paste.ahk) assume that the previous paste performed was empty, causing it to type out all the text again.
- To make [Paste.ahk](Paste.ahk) assume that ComputerCraft or whatever program already has the current clipboard contents, press Shift-Alt-o. In other words, after pressing this, then the next time you paste, there will be no changes to the contents in ComputerCraft or whatever program.

## Development usage
1. Clone this repo with `git clone --recursive https://github.com/sbond75/PasteTyper.git`, or clone it and then use `git submodule update --init --recursive` in the repo root.
2. Create a Python venv: `python -m venv .venv`
3. Install the pylcs folder included with the repo: `pip install pylcs/`. This provides diffing features for [differ.py](differ.py)`. If not present, a much slower algorithm will be used.
4. Install AutoHotkey. It is unknown if the latest version works. If not, try [v1.1.24.00](https://www.autohotkey.com/download/1.1/AutoHotkey112400_Install.exe) which is known to work (non-installer version [here](https://www.autohotkey.com/download/1.1/AutoHotkey112400_x64.zip)).
5. Open [Paste.ahk](Paste.ahk) with AutoHotkey.

## Project structure
- [Paste.ahk](Paste.ahk) contains the AutoHotkey program.
- [differ.py](differ.py) contains a diffing function `diff` which is used by [diffs.py](diffs.py).
- [diffs.py](diffs.py) is called by [Paste.ahk](Paste.ahk) to perform diffing on the previously pasted contents with the current clipboard.
