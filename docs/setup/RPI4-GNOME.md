# Raspberry Pi 4 - Gnome Wayland

Im folgenden Abschnitt ist beschrieben, wie Gnome auf einem RaspberryPi 4
aufgesetzt werden kann. Der hier beschriebene Prozess ist der empfohlenen
Ablauf, zum Aufsetzen der Desktop umgebunge, in welcher dieKlingel läuft

1. Den Raspberry Pi Imager herunterladen
    - Der Raspberry Pi Imager kann von hier
      <https://www.raspberrypi.com/software/> heruntergeladen werden.

    - Dann kann das OS `Raspberry Pi OS Lite (64-bit)` auf die SD-Karte
      geflasht werden.

2. Desktop installieren
    - In der Konsole des Raspis wird zuerst ein Update gemacht.

    - Dann wird mit sudo tasksel ein Menü geöffnet. Hier sollte

      ```bash
      Debian desktop environment
      ... GNOME
      ```

      mittels der Leertaste ausgewählt werden.

3. Desktop als Default Boot Option setzen
   Nachdem nun Gnome auf dem Raspi installiert ist, kann mit

   ```bash
   sudo systemctl set-default graphical.target
   ```

   die Graphische Oberfläche als Default gesetzt werden. Nach einem weiteren
   Neustart sollte der Raspi nun in Gnome starten. Alle weiteren Einstellungen
   können in der Einstellungen App von Gnome ausgeführt werden.

4. Denn Networkmanager dem Autostart hinzufügen
  
## Konfiguration

Nachdem der Display installiert ist, können noch ein paar dinge konfiguriert werden:

- AutoLogin
- Display drehen
- Vnc aktiviern
- Inaktivitätsmeldung deaktivieren

    ```bash
    gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing'
    ```

## Known Issues

- Display Drehen

Beim Drehen des Displays in Gnome wurde der Touch nicht mitgedreht. Dies kann
behoben werden indem eine Datei unter
`/etc/udev/rules.d/98-touchscreen-cal.rules` erstellt wird. Die Datei sollte
folgenden Inhanlt haben um alle Toucheingabegeräte um 90° zu drehen.

```rules
ENV{LIBINPUT_CALIBRATION_MATRIX}="0 -1 1 1 0 0 0"
```

Nach einem Neustart, sollte die Toucheingabe um 90° im Uhrezigersinn gedreht
sein. Je nach Bildschrimausrichtung, kann die Rotationsmatrix angepasst werden.

- Screen Sharing
Screen Sharing wurde in den Einstellungen aktiviert, jedoch kann der Raspi nicht
mit der Maus gesteuert werden.

- Die Anwendung startet im Vollbildmodus, kann aber durch wischen von oben nach unten minimiert werden.
Die Packetquellen in `/etc/apt/sources.list` sollten wie folgt gewählt sein:

```bash
deb http://deb.debian.org/debian bullseye main contrib non-free
deb http://security.debian.org/debian-security bullseye-security main contrib non-free
deb http://deb.debian.org/debian bullseye-updates main contrib non-free
# Uncomment deb-src lines below then 'apt-get update' to enable 'apt-get source'
# deb-src http://deb.debian.org/debian bullseye main contrib non-free
# deb-src http://security.debian.org/debian-security bullseye-security main contrib non-free
```
