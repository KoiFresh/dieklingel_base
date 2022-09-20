# Fhem dieKlingel

Im folgenden Dokument ist Beschrieben, wie Fhem auf einem RaspberryPi 4
aufgesetzt und Konfiguriert werden kann, so das dies in Verbindung mit
der Klingel funktioniert und als Schnittstelle dient.

1. Fhem auf dem Raspberry Pi installieren.
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

2. Fhem konfigurieren
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
