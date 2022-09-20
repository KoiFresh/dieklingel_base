# Setup dieKlingel

dieKlingel Basis kann derzeit in einer Browser basiertemn Laufzeitumgebung
als Basis verwendet werden. Damit die Klingel funktioniert ist außerdem ein Mqtt Broker erforderlich.
Im folgenden Abschnitt sind alle Dokumente in jener Reihenfolge verlinkt, wie die Basis vollständig auf Raspberry Pi 4 aufgesetzt werden kann.

1. Betriebssystem und Display Manager aufsetzten
    [Raspberry Pi 4 - Gnome Wayland](rpi4-gnome.md)
2. MQTT Broker installieren
    [Mosquitto MQTT Broker](mosquitto.md)
3. Basis kompillieren
    [dieKlingel Basis](dieklingel-build.md)
4. Browser bassierete Laufzeitumgebung aufsetzten
    [Firefox ESR dieKlingel Laufzeitumgebung](firefox-runtime.md) (empfohlen)
    [Chromium dieKlingel Laufzeitumgebung](chromium-runtime.md)
5. Service Unit anlegen
    [Service Unit Debian](service-unit-debian.md)
6. Fhem als Controller
    [Fhem als dieKlingel Controller](fhem.md)
