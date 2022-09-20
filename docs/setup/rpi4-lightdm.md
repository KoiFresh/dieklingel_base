# Raspberry Pi 4 - LightDM Wayland

Im folgenden Abschnitt ist beschrieben, wie Gnome auf einem RaspberryPi 4
aufgesetzt werden kann. Der hier beschriebene Prozess ist der empfohlenen
Ablauf, zum Aufsetzen der Desktop Umgebung, in welcher dieKlingel läuft.

1. Den Raspberry Pi Imager herunterladen
    - Der Raspberry Pi Imager kann von hier
      <https://www.raspberrypi.com/software/> heruntergeladen werden.

    - Dann kann das OS `Raspberry Pi OS (64-bit)` auf die SD-Karte
      geflasht werden.

2. Display Drehen
   Mit dem automatisch mit-installiertem Tool ScreenConfifurator kann der Bildschirm gedreht werden.
   Das Tool ist nur über die GUI erreichbar, wenn Wayland nicht aktiviert ist.

3. Wechsel zu Wayland anstelle von X11 ⚠️(derzeit nicht empfohlen)

    ```bash
    sudo raspi-config
    ```

    ```bash
    6 Advanced Options 
      A9 Wayland
        Enable - <Yes>
    ```

4. Raspi Legacy Camera aktivieren

    ```bash
    sudo raspi-config
    ```

    ```bash
    3 Interfacing Options
      I1 Legacy Camera
        Enable - <Yes>
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
