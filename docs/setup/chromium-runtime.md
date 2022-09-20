# Chromium dieKlingel Laufzeitumgebung

In diesem Dokument ist beschrieben wie Chromium als Laufzeitumgebung für
die Klingel verwendet werden kann.

1. Chromium installieren

     ```bash
     sudo apt-get install chromium-browser
     ```

2. Ausführen
    Die Klingel kann nun mit Chromium als Laufzeit Umgebung ausgeführt werden.

    - Für die Ausfühurng unter Wayland

        ```bash
        /usr/bin/chromium-browser --enable-features=UseOzonePlatform --ozone-platform=wayland --noerrdialogs --disable-infobars --allow-file-access-from-files --use-fake-ui-for-media-stream --kiosk /home/pi/dieklingel_base/build/web/index.html
        ```

    - Für die Ausführung unter X11

        ```bash
        /usr/bin/chromium-browser --noerrdialogs --disable-infobars --allow-file-access-from-files --use-fake-ui-for-media-stream --kiosk /home/pi/dieklingel_base/build/web/index.html
        ```
