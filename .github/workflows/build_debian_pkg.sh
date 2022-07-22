#!/bin/bash

mkdir -p debian/usr/share
cp -r build/web debian/usr/share/dieklingel

mkdir -p debian/usr/local/bin
ln -sfr debian/usr/share/dieklingel/runner.py  debian/usr/local/bin/dieklingel

VERSION=$(cat pubspec.yaml | grep -Po '(?<=version:\s)(.*)')
sed -i "s/{{VERSION}}/$VERSION/g" debian/DEBIAN/control

# actual build prozess 
dpkg-deb --build debian
mv debian.deb dieklingel_$VERSION.deb

