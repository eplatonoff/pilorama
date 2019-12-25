# Pilorama

![header image](https://github.com/eplatonoff/pilorama/blob/master/img/cover.png)

*Advanced [Timeboxing](https://en.wikipedia.org/wiki/Timeboxing) timer.*

## Key Features
- Simple countdown timer
- Infinite time boxing timer
- Night mode
- System notifications
- Dynamic tray icon and menu
- JSON Presets
- Cross-platform software


## Installation [![semver](https://img.shields.io/github/v/release/eplatonoff/pilorama)](https://github.com/eplatonoff/pilorama/releases/latest/) [![semver](https://img.shields.io/github/release-date/eplatonoff/pilorama)](https://github.com/eplatonoff/pilorama/releases/latest/)

### MacOS and Windows

Precompiled builds available [here](https://github.com/eplatonoff/pilorama/releases/latest/).

### Linux [![Build Status](https://travis-ci.com/eplatonoff/pilorama.svg?branch=master)](https://travis-ci.com/eplatonoff/pilorama)

> Tip: Archlinux [AUR](https://wiki.archlinux.org/index.php/Arch_User_Repository) package [`pilorama-git`](https://aur.archlinux.org/packages/pilorama-git/) available.

Building from source:

    $ sudo pacman -S qt5-quickcontrols qt5-quickcontrols2 qt5-graphicaleffects qt5-multimedia  # Archlinux
    $ sudo apt install qt5-default qtdeclarative5-dev libqt5svg5-dev  # Ubuntu Bionic

    $ git clone https://github.com/eplatonoff/pilorama
    $ cd pilorama
    $ qmake src/pilorama.pro 
    $ make
    $ ./pilorama
