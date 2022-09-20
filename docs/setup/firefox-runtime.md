# Firefox ESR dieKlingel Laufzeitumgebung

In diesem Dokument ist beschrieben wie Firefox ESR als Laufzeitumgebung für
die Klingel verwendet werden kann.

1. Firefox ESR installieren

     ```bash
     sudo apt-get install firefox-esr
     ```

2. Firefox starten

    ```bash
    firefox-esr
    ```

    Nach dem ersten start von Firefox wird ein Ordner für ein dfefault
    Profile angelegt. Der Ordner befindet sich unter
    `~/.mozilla/firefox/*.default-esr`

3. Einstelluungen vornehemen
    Die Datei `user.js` wird beim Start von Firefox ausgeführt und die
    Einstellungen werden angewandt.

    ```bash
    sudo nano ~/.mozilla/firefox/*.default-esr/user.js
    ```

    Die empfohlenen Einstellungen für die Klingel sind hier aufgelistet:

    ```javascript
    user_pref("privacy.file_unique_origin", false);
    user_pref("permissions.default.microphone", 1);
    user_pref("permissions.default.camera", 1);
    user_pref("privacy.webrtc.legacyGlobalIndicator", false);
    user_pref("gfx.webrender.all", true);
    ```

4. Ausführen
    Die Klingel kann nun mit Firefox ESR als  Laufzeit Umgebung ausgeführt werden.

    ```bash
    firefox-esr --new-instance --kiosk /home/pi/dieklingel_base/build/web/index.html
    ```

    Soll die Anwendung z.B. über SSH gestartet werden, so muss dem Befehl
    bei verwendung von:

    * Wayland ➝ `WAYLAND_DISPLAY=wayland-0` (empfohlen)
    * X11 ➝ `DISPLAY=:0`

    vorangestellt werden
