# Service Unit Debian

In diesem Dokument ist eine beispielhafte Konfiguration einer Service-einheit auf einem
Debian System beschscrieben, mit welchem dieKlingel gestartet/gestoppt oder der Autostart
z.B. nach einem Reboot aktiviert werden kann.

Eine Service Datei anlegen:

```bash
cd /etc/systemd/user
nano dieklingel.service
```

In die Datei kommt nun folgender inhalt:

```bash
[Unit]
Description=dieklingel base

[Service]
Type=simple
Environment="DISPLAY=:0"
ExecStart=/usr/bin/chromium-browser --noerrdialogs --disable-infobars --allow-file-access-from-files --use-fake-ui-for-media-stream --kiosk /home/pi/dieklingel_base/build/web/index.html

[Install]
WantedBy=default.target
```

❕ Hierbei muss der Pfad am ende des Befehls `ExecStart` dem Pfad der index.html
Datei des kompilierten Projekts entsprechen. Bei dieser Konfiguration handelt
es sich um ein Beispiel mit
[Chromium  als Laufzeitumgebung](chromium-runtime.md). Soll statdessen
Firefox als Laufzeitumgebung verwendet werden, so muss der Befehlt unter
`ExecStart` an den Befeh von
[Firefox ESR als Laufzeitumgebung](firefox-runtime.md) angepasst werden.

Nun sind die Folgenden Befehle möglich um:

* 🚀 Die Anwendung zu staren:

    ```bash
    systemctl --user start dieklingel
    ```

* ✋ Die Anwendung zu stoppen:

    ```bash
    systemctl --user stop dieklingel
    ```

* 🚗 Autostart aktivieren:

    ```bash
    systemctl --user enable dieklingel
    ```

* 🔄 Die Anwendung neu zu starten:

    ```bash
    systemctl --user restart dieklingel
    ````
