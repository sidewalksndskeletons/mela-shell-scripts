#!/bin/sh

rrt() {
    if [ -z "$XDG_RUNTIME_DIR" ]; then
        export XDG_RUNTIME_DIR=/tmp/run/$(id -u)
        mkdir -p "$XDG_RUNTIME_DIR"
        chmod 0700 "$XDG_RUNTIME_DIR"
    fi
}

# this is usally sits on my .ashrc but i wanted to put here too
