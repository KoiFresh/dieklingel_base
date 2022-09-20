# Konfiguration

Die Basis wird beim start der Anwendung einmalig mit einer Konfigurationsdatei initialisiert.
Die Konfigurationsdatei ist under dem Pfad `resources/config/config.json` zu finden.

Im Debian Packet der Anwendung, befindet sich die Konfigurationsdatei unter dem Pfad `/etc/dieklingel/config.json`.
Unter `resources/config/config.json` liegt hier eine Verknüpfung, welche auf die Konfigurationsdatei unter
`/etc/dieklingel/config.json` verweist.

Die Konfigurationsdatei ist im `json` Format. Und Sollte wie folgt aufgebaut sein:

```json
{
  "uid": "com.dieklingel/mustermann/main/",
  "webrtc": {
    "ice": {
      "iceServers": [
        {
          "url": "stun:stun1.l.google.com:19302"
        },
        {
          "url": "turn:dieklingel.com:3478",
          "credential": "guest_credential",
          "username": "guest"
        }
      ]
    }
  },
  "mqtt": {
    "address": "127.0.0.1",
    "port": 9001
  },
  "notification": {
    "snapshot": false
  },
  "viewport": {
    "clip": {
      "top": 10,
      "right": 10,
      "bottom": 10,
      "left": 10
    },
    "screensaver": {
      "text": "1",
      "autoenable": true,
      "timeout": 30
    }
  },
  "signs": [
    {
      "text": "<span style='font-weight: bold;'>Hello World!</span>",
      "hash": "#default"
    },
    {
      "text": "I am a Sign!",
      "hash": "#asign"
    }
  ]
}
```

Im nachfolgenden Abschnitt sind die Details Eigenschaften beschrieben:

- ### uid: string

  Die uid ist eine eindeutige ID, anhand welcher die Basis Identifiziert wird. Die uid gibt auch
  den Prefix der Mqtt-Kanäle an, über welche die Basis Kommuniziert. Die uid sollte in jedem Fall mit
  einem `/` enden, so wird sichergestellt, das der benutze Kanal ein Sub-Kanal ist.

- ### webrtc.ice.iceServers: List\<IceServer\>

  Eine Liste aller Stun und/oder Turn Server, welche von der Basis verwendet werden können. Ein Server
  muss jeweils aus einer url bestehen. Falls vorhanden und benötigt, so optional der Nutzname und das
  Passwort des jeweiligen Servers angegeben werden.

- ### mqtt.address: string

  Die Domain/IP Adresse, des Mqtt-Brokers, mit welchem sich die Basis verbinden soll.

- ### mqtt.port: int

  Der Port, des Mqtt-Brokers, mit welchem sich die Basis verbinden soll.

- ### mqtt.username: string (Not Implemented)

  Der Benutzername, mit welchem sich die Basis beim Mqtt-Broker anmeldet. Falls kein Benutzername
  benötigt wird, kann das Feld aus der Konfigurationsdatei gelöscht werden.

- ### mqtt.password: string (Not Implemented)

  Das Passwort, mit welchem sich die Basis beim Mqtt-Broker anmeldet. Falls kein Passwort
  benötigt wird, kann das Feld aus der Konfigurationsdatei gelöscht werden.

- ### notification.snapshot: bool

  Ist Snapshot auf `true` gesetzt, so versucht die Basis nachdem geklingelt wurde ein Bild der Kamera aufzunehemen.
  Das Bild wird dann dem Payload der Benachrichtifung angegängt. Ist Snapshot auf `false` gesetzt, so bleibt der image payload
  innerhalb der Benachrichtigung leer.

- ### viewport.clip.top: int

  Gibt die Anzahl an Pixel an, um die die obere Kante des Viewports vom oberen Bildschrimrand nach unten verschoben wird.
  Anstelle des Werts `0`, kann das Feld auch aus der Konfigurationsdatei gelöscht werden.

- ### viewport.clip.right: int

  Gibt die Anzahl an Pixel an, um die die rechte Kante des Viewports vom rechten Bildschrimrand nach links verschoben wird.
  Anstelle des Werts `0`, kann das Feld auch aus der Konfigurationsdatei gelöscht werden.

- ### viewport.clip.bottom: int

  Gibt die Anzahl an Pixel an, um die die untere Kante des Viewports vom unteren Bildschrimrand nach oben verschoben wird.
  Anstelle des Werts `0`, kann das Feld auch aus der Konfigurationsdatei gelöscht werden.

- ### viewport.clip.left: int

  Gibt die Anzahl an Pixel an, um die die linke Kante des Viewports vom linken Bildschrimrand nach rechts verschoben wird.
  Anstelle des Werts `0`, kann das Feld auch aus der Konfigurationsdatei gelöscht werden.

- ### viewport.screensaver.text: string

  Der Text, welcher auf dem Bildschirmschoner (Display State: off) dargestellt wird. Anstell von einfachem Text, kann der
  Text mittels Html strukturiert und mittels Css gestaltet werden. z.B. `<span style='color: green'>Hallo</span>`.

- ### viewport.screensaver.autoenable: bool (Not Implemented)

  Gibt an ob der Bildschirmschoner automatisch nach eine Timeout an Inaktiviöt aktiviert werden soll

- ### viewport.screensaver.timeout: int (Not Implemented)

  Legt den Timeout in Sekunden fest, nach denen dieKlingel in den Bildschirmschoner wechselt, wenn für die
  Dauer des Timeouts keine Aktivität festgelegt wurde. Dies geschieht nur, wenn `viewport.screensaver.autoenable` auf `true`
  gesetzt ist, andernfalls hat der Timeout keine Auswirkung.

- ### signs: List\<Sign\>

  Eine List aus Schildern, welche von der Basis dargestellet werden. Jedes Schild benötigt einen Text, welcher vom Schild angezeigt wird.
  Der Text kann anstelle von einfachem Text auch mit Html gestaltet werden.
  Zudem benötigt jedes schild noch einen Hash, durch welchen das Schild eindeutig zu identifiziern sein sollte. Ein gerät, welches ein bestimmtes
  Schild ansprechen wird, wird dies über den Hash des Schildes tun. So registriert sich ein Gerät für Benachtrichtugen etwa auf einen bestimmten Hash.
  Ein Hash startet immer mit `#`;
