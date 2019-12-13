# Pilorama

*Advanced [Timeboxing](https://en.wikipedia.org/wiki/Timeboxing) timer.*

## Key Features
- Simple countdown timer
- Infinite time boxing timer
- Night mode
- System notifications
- Dynamic tray icon and menu
- JSON Presets


## Building on Archlinux

    $ sudo pacman -S qt5-quickcontrols qt5-quickcontrols2 qt5-graphicaleffects qt5-multimedia
    $ git clone https://github.com/eplatonoff/pilorama
    $ cd pilorama
    $ qmake src/pilorama.pro 
    $ make
    $ ./pilorama
