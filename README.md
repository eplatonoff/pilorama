![header image](/assets/cover.png?raw=true)

# <a href="//pilorama.app">Pilorama</a>

*Advanced [Timeboxing](https://en.wikipedia.org/wiki/Timeboxing) Tool*

## Key Features
- Cross-platform software
- Simple countdown timer
- Infinite time boxing timer
- System notifications
- Dynamic tray icon and menu
- JSON Presets
- Night mode
- Optional pause button


## Installation

[![GitHub Release Version](https://img.shields.io/github/v/release/eplatonoff/pilorama)](https://github.com/eplatonoff/pilorama/releases/latest/) [![GitHub Release Date](https://img.shields.io/github/release-date/eplatonoff/pilorama?label=release%20date)](https://github.com/eplatonoff/pilorama/releases/latest/) [![GitHub Downloads](https://img.shields.io/github/downloads/eplatonoff/pilorama/total)](https://github.com/eplatonoff/pilorama/releases/latest/)

### MacOS and Windows

Precompiled builds are available [here](https://github.com/eplatonoff/pilorama/releases/latest/).

### Linux

> Tip: Archlinux [AUR](https://wiki.archlinux.org/index.php/Arch_User_Repository) package [`pilorama-git`](https://aur.archlinux.org/packages/pilorama-git/) available.

Building from source:

    $ sudo apt install build-essential cmake qt6-declarative-dev libqt6svg6-dev qt6-base-dev qt6-multimedia-dev qml6-module-qt-labs-platform qml6-module-qt-labs-settings qml6-module-qtmultimedia qml6-module-qtquick-controls qml6-module-qtquick-controls qml6-module-qtquick-dialogs  # Ubuntu 24.04

    $ git clone https://github.com/eplatonoff/pilorama
    $ cd pilorama
    $ mkdir build
    $ cd build
    $ cmake ../src
    $ make -j
    $ ./Pilorama


## Development / Code of Conduct 
#### Release Process

Once the latest **Pull Request** passed all CI checks & **are merged** to master **push git tag** with required version pointed **to** merge commit on **master** branch.  
**GitHub Actions** proccesses this tag & **builds** all **distributions**. After that **it also makes version bumps** & pushes it **to master** as a separate commit.
