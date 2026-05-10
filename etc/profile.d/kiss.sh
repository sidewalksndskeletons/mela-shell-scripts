#!/bin/sh

export KISS_PATH=''
KISS_PATH=$KISS_PATH:/home/swasmi/repos/core
KISS_PATH=$KISS_PATH:/home/swasmi/repos/extra
KISS_PATH=$KISS_PATH:/home/swasmi/repos/flatpak
KISS_PATH=$KISS_PATH:/home/swasmi/repos/wayland
KISS_PATH=$KISS_PATH:/home/swasmi/repos/xwayland
KISS_PATH=$KISS_PATH:/home/swasmi/repos/apps

export KISS_COMPRESS=''
KISS_COMPRESS=xz

export CFLAGS="-O3 -pipe -march=native -fno-plt"
export CXXFLAGS="$CFLAGS"
export LDFLAGS="-Wl,-O1,--as-needed"
export MAKEFLAGS="-j12"
export SAMUFLAGS="$MAKEFLAGS"

export TZ=''
TZ='<+03>-3'

export LANG=C.UTF-8
export LC_ALL=C.UTF-8
export LC_CTYPE=C.UTF-8

export DISABLE_RTKIT=1

# this one does not count as "mela" but i wanted to add it here too lol
