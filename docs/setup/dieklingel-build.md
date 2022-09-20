# dieKlingel Basis

In diesem Dokument ist beschrieben, wie dieKlingel auf einem 64-Bit auf Linux
basierendem Betriebssystem compiliert werden kann. In dem hier beschriebenen
Vorgang wird dieKlingel so kompilliert, das diese mit Firefox (oder chromium)
als Laufzeitumgebung läuft. So wie dies in den Dokumenten
[Firefox ESR](firefox-runtime.md) und [Chromium](chromium-runtime.md)
beschrieben ist.

1. Flutter SDK installieren
    Das Flutter SDK kann wie hier
    <https://docs.flutter.dev/get-started/install/linux>n beschrieben
    installiert werden.

2. dieKlingel Projekt klonen

    ```bash
    git clone https://github.com/KoiFresh/dieklingel_base.git
    ```

3. Projekt kompilieren

    ```bash
    cd dieklingel_base
    flutter build web
    ```
