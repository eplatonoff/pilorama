# Pilorama

*An QML-based [Pomodoro timer](https://en.wikipedia.org/wiki/Pomodoro_Technique).*


## Building on Archlinux

    $ sudo pacman -S qt5-quickcontrols qt5-quickcontrols2 qt5-graphicaleffects qt5-multimedia
    $ git clone https://github.com/eplatonoff/pilorama
    $ cd pilorama
    $ qmake src/pilorama.pro 
    $ make
    $ ./pilorama
