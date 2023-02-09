/// Mqtt-channel used to for the current state of the display. Possible Values
/// are "on" and "off", other values will be ignored. If "screensaver.enabled"
/// is set to false this value will be ignored, if set to true, this value will
/// switch to false with the activity value.
const String kIoDisplayState = "io/display/state";

/// Mqtt-channel used to emit that a sign has been clicked recently. Every
/// following system e.g. fhem should instantly react to this event, by informing
/// the user about the Event. A user defines payload is send within the event,
/// to determinate devices, bells or other folling up systems.
/// The message will have the folling json format:
///
/// ```json
/// {
///   "identifier": "<the identifier used for the sign>",
///   "payload": [
///     "<any payload stored for this identifier>"
///   ]
/// }
/// ```
const String kIoActionSignClicked = "io/action/sign/clicked";

/// Mqtt-channel used to emit the activity state. Possible Values are
/// `active` and `inactive`, all other values will be ignored. If
/// `screensaver.enables` is set to `true`, this will also the the display
/// state.
const String kIoActivityState = "io/activity/state";

/// Mqtt-channel used to send a readable ping to the system. Provides the
/// Possibility to implement a Health-Checker, and or get the systems time
/// distance. The payload is the current syste date time.
const String kSystemPing = "system/ping";
