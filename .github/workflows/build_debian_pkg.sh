#!/bin/bash

mkdir -p debian/usr/share
cp -r build/web debian/usr/share/dieklingel

mkdir -p debian/usr/local/bin
ln -sfr debian/usr/share/dieklingel/runner.py  debian/usr/local/bin/dieklingel

VERSION=$(cat pubspec.yaml | grep -Po '(?<=version:\s)(.*)')
sed -i "s/{{VERSION}}/$VERSION/g" debian/DEBIAN/control

# copy settings
mkdir -p debian/etc/dieklingel
cp debian/usr/share/dieklingel/assets/resources/config/config.json debian/usr/share/dieklingel/assets/resources/config/config.json.backup
cp debian/usr/share/dieklingel/assets/resources/config/config.json debian/etc/dieklingel
ln -sfr debian/etc/dieklingel/config.json debian/usr/share/dieklingel/assets/resources/config/config.json

# actual build prozess 
dpkg-deb --build debian
mv debian.deb dieklingel_$VERSION.deb
