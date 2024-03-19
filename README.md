# dieklingel_base

> 2024-03-19 NOTE: you probably should no longer use `dieklingel_base`. If you where looking for the dieKlingel project, checkout <https://dieklingel.com/>. If you intended to navigated to the `dieklingel_base` repository, you should migrate to [dieklingel-core](https://github.com/koifresh/dieklingel-core/).

![alt dieKlingel Logo und Text](https://dieklingel.de/_nuxt/image/5577c6.webp)

Dieses Projekt beinhaltet die Basis des dieKlingel Projeckts.

## Build

1. Build abhängigkeiten installieren:
    Um dieses Projekt zu bauen wird das Flutter SDK benötigt, wie dies installiert werden kann, kann hier nachgelesen werden.
    <https://docs.flutter.dev/get-started/install/linux>

2. Build
    Folgende befehle müssen ausgeführt werden, um das Projekt zu Bauen.

    ```bash
    flutter pub get
    flutter build web
    ```

### Run

1. Laufzeit-abhägingkeiten installieren:
    um die Anwendung auszuführen, wird chromium benötigt.

    ```bash
    sudo apt-get install chromium-browser
     ```

2. Anwendung ausführen:

    ```bash
    chromium-browser --noerrdialogs --disable-infobars --allow-file-access-from-files --kiosk build/web/index.html &> /dev/null
    ```
