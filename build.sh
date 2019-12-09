#!/bin/sh

for dep in $(grep dependency meson.build | awk -F"'" '{print $2}'); do
    dub fetch $dep # may fail on local deps
    dub build $dep
done

meson build
echo "Ready! ninja in build/ to build."
