# Raspberry Pi 4 - Gnome Wayland

Im folgenden Abschnitt ist beschrieben, wie Gnome auf einem RaspberryPi 4
aufgesetzt werden kann. Der hier beschriebene Prozess ist der empfohlenen
Ablauf, zum Aufsetzen der Desktop Umgebung, in welcher dieKlingel läuft.

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

   die Graphische Oberfläche als Default gesetzt werden.

4. Denn Networkmanager dem Autostart hinzufügen

    ```bash
    sudo systemctl enable NetworkManager
    ```

    Nach einem weiteren Neustart sollte der Raspi nun in Gnome starten. Alle
    weiteren Einstellungen können in der Einstellungen App von Gnome
    ausgeführt werden.

## Konfiguration

Nachdem der Display Manager installiert ist, können noch ein paar dinge konfiguriert werden:

- AutoLogin
- Display drehen
- VNC aktiviern
- 'Bildschirm automatisch ausschalten' deaktivieren

    ```bash
    gsettings set org.gnome.ControlCenter last-panel 'power'
    gsettings set org.gnome.desktop.session idle-delay uint32 0
    ```

- Inaktivitätsmeldung deaktivieren

    ```bash
    gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing'
    ```

## Known Issues

- ✅ Display Drehen

Beim Drehen des Displays in Gnome wurde der Touch nicht mitgedreht. Dies kann
behoben werden indem eine Datei unter
`/etc/udev/rules.d/98-touchscreen-cal.rules` erstellt wird. Die Datei sollte
folgenden Inhanlt haben um alle Toucheingabegeräte um 90° zu drehen.

```rules
ENV{LIBINPUT_CALIBRATION_MATRIX}="0 -1 1 1 0 0 0"
```

Nach einem Neustart, sollte die Toucheingabe um 90° im Uhrezigersinn gedreht
sein. Je nach Bildschrimausrichtung, kann die Rotationsmatrix angepasst werden.

- ⚠️ Screen Sharing
Screen Sharing wurde in den Einstellungen aktiviert, jedoch kann der Raspi
nicht mit der Maus gesteuert werden.
