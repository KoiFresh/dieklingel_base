# Mosquitto MQTT Broker

In diesem Dokument ist beschrieben wie [Mosquitto](https://mosquitto.org/) als MQTT Broker für
die Klingel verwendet werden kann.

1. Mosquitto installieren

    ```bash
    sudo apt-get install mosquitto
    ```

2. Mosquitto Konfigurieren

    - Neue Konfigurationsdatei anlegen

      ```bash
      sudo touch /etc/mosquitto/conf.d/dieklingel.conf
      ```

    - Listener hinzufüghen
      In der Konfigurationsdatei sollte ein Listener für Mqtt über Websockets
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

3. Mosquitto neustarten

    ```bash
    sudo systemctl restart mosquitto
    ```

    Der Autostart ist bei Mosquitto standardmäßig aktiviert.
