# Setup

Im folgenden Dokument ist beschrieben, wie eine Konfiguration der Klingel auf
einem Raspberry Pi, mit Mosquitto als Mqtt-Broker und Fhem als Smarthome System
aussehen könnte. Als ausgangspunkt haben wir einen fertig eingerichteten
Rasperry Pi mit 7 Zoll HDMI Bildschirm.

1.  Mosquitto auf dem Raspberry Pi installieren

    ```bash
    sudo apt-get install mosquitto
    ```

2.  Mosquitto Konfigurieren

    - Neue Konfigurationsdatei anlegen

      ```bash
      sudo touch /etc/mosquitto/conf.d/dieklingel.conf
      ```

    - In der Konfigurationsdatei sollte ein Listener für Mqtt über Websockets
      hinzugefügt werden. Wenn Keine Anmeldedaten verwendet werde sollen, dann
      muss auch `allow_anonymous true` der Datei angefügt werden. Zudem, kann
      der Broker mit einem öffentlichen Broker verbunden werden, so ist die
      Kommunikation mit der Basis nicht nur aus dem Heimnetz verfügbar.

      ```conf
      allow_anonymous true

      listener 1883

      listener 9001
      protocol websockets

      #connection dieklingel

      connection dieklingel-public
      address server.dieklingel.com:1883
      topic com.dieklingel/name/door/# both 0
      ```

    In der Konfigurationsdatei muss unter `topic` der wert
    `com.dieklingel/name/door/` mit dem Kanalprefix der Basis ersetzt werden.
    Der Kanalprefix ist in `config.json` unter `uid` zu finden.

    - Nun muss noch mosquitto neu gestartet werden, um die änderungen zu übernhemen.

      ```bash
      sudo systemctl restart mosquitto
      ```

3.  Fhem auf dem Raspberry Pi installieren.

    - Abhäigikeiten Installieren

      ```bash
      sudo apt-get -y install perl-base libdevice-serialport-perl libwww-perl
      libio-socket-ssl-perl libcgi-pm-perl libjson-perl sqlite3
      libdbd-sqlite3-perl libtext-diff-perl libtimedate-perl
      libmail-imapclient-perl libgd-graph-perl libtext-csv-perl libxml-simple-perl
      liblist-moreutils-perl fonts-liberation libimage-librsvg-perl
      libgd-text-perl libsocket6-perl libio-socket-inet6-perl libmime-base64-perl
      libimage-info-perl libusb-1.0-0-dev libnet-server-perl

      sudo apt-get -y install libdate-manip-perl libhtml-treebuilder-xpath-perl
      libmojolicious-perl libxml-bare-perl libauthen-oath-perl
      libconvert-base32-perl libmodule-pluggable-perl libnet-bonjour-perl
      libcrypt-urandom-perl
      ```

    - Fhem herunterladen

      ```bash
      sudo wget http://fhem.de/fhem-6.0.deb
      ```

    - Fhem installieren

      ```bash
      sudo dpkg -i fhem-6.0.deb
      ```

    Fhem ist jetzt unter der IP des Raspberry Pi's und dem Port 8083 erreichbar.

4.  Fhem konfigurieren
    Die Konfiguration von Fhem findet hier in der Befehlszeileneingabe auf der
    Weboberfläche von Fhem statt.

    - Mqtt Broker anlegen

      ```fhem
      define dieklingel_mosquitto MQTT 127.0.0.1:1883
      ```

    - Die Basis als Gerät in Fhem anlegen

      ```bash
      define dieklingel MQTT_DEVICE dieklingel_mosquitto
      ```

    - Readings der Klingel anlegen
      Hierbei muss `<PREFIX>` durch den Mqtt Kanalprefix ersetzt werden.

      ```bash
      attr dieklingel subscribeReading_io_display_state <PREFIX>io/display/state
      attr dieklingel subscribeReading_io_action_unlock_passcode <PREFIX>io/action/unlock/passcode
      attr dieklingel subscribeReading_system_log <PREFIX>system/log
      attr dieklingel subscribeReading_firebase_notification_send <PREFIX>firebase/notification/send
      attr dieklingel subscribeReading_rtc_call_state <PREFIX>rtc/call/state

      attr dieklingel publishSet_io_display_state <PREFIX>io/display/state
      ```

5.  Den gewünschten Release, dieses Repositories herunterladen

    ```bash
    wget https://github.com/KoiFresh/dieklingel_base/releases/download/v1.0.0+2/dieklingel_1.0.0+2.deb
    ```

6.  Den geladenen Release installieren.

    ```bash
    sudo apt-get install ./dieklingel_1.0.0+2.deb
    ```

7.  Die Basis Konfigurieren.
    Nun kann die Basis so Konfiguriert werden, welche Einstellungen hierbei vorgenommen werden
    können, ist unter [Konfiguration](../config/README.md) zu finden.

8.  Den Autostart der Anwendung einrichgten
    Eine Datei für den Autostart erstellen, nachdem sich ein Nutzer angemeldet hat.

    ```bash
    mkdir /home/pi/.config/autostart
    touch /home/pi/.config/autostart/dieKlingel.desktop
    ```

    Diese sollte folgenden Inhalt haben:

    ```desktop
    [Desktop Entry]
    Type = Application
    Name = dieKlingel
    Exec = /usr/local/bin/dieklingel
    ```
