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


## Installation [![GitHub Release Version](https://img.shields.io/github/v/release/eplatonoff/pilorama)](https://github.com/eplatonoff/pilorama/releases/latest/) [![GitHub Release Date](https://img.shields.io/github/release-date/eplatonoff/pilorama?label=release%20date)](https://github.com/eplatonoff/pilorama/releases/latest/) [![GitHub Downloads](https://img.shields.io/github/downloads/eplatonoff/pilorama/total)](https://github.com/eplatonoff/pilorama/releases/latest/)

### MacOS and Windows

Precompiled builds are available [here](https://github.com/eplatonoff/pilorama/releases/latest/).

### Linux

> Tip: Archlinux [AUR](https://wiki.archlinux.org/index.php/Arch_User_Repository) package [`pilorama-git`](https://aur.archlinux.org/packages/pilorama-git/) available.

Building from source:

    $ sudo pacman -S qt5-quickcontrols qt5-quickcontrols2 qt5-graphicaleffects qt5-multimedia  # Archlinux
    $ sudo apt install qt5-default qtdeclarative5-dev libqt5svg5-dev  # Ubuntu Bionic

    $ git clone https://github.com/eplatonoff/pilorama
    $ cd pilorama
    $ qmake src/pilorama.pro 
    $ make
    $ ./pilorama


## Development / Code of Conduct  [![GitHub Workflow Status](https://img.shields.io/github/workflow/status/eplatonoff/pilorama/Pull%20Request?label=GitHub%20Actions)](https://github.com/eplatonoff/pilorama/actions) [![Travis (.com)](https://img.shields.io/travis/com/eplatonoff/pilorama?label=Travis%20CI)](https://travis-ci.com/eplatonoff/pilorama)

#### Release Process

Once the latest **Pull Request** passed all CI checks & **are merged** to master **push git tag** with required version pointed **to** merge commit on **master** branch.  
**GitHub Actions** proccesses this tag & **builds** all **distributions**. After that **it also makes version bumps** & pushes it **to master** as a separate commit.

