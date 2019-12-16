# Rubber-Side-Down
A motorcycle safety app for iOS that uses CoreMotion to detect when the user's bike has been tipped over. Sends an SMS to a list of 
contacts with the rider's description and location. Users must use a strong phone mount to attach the device securely to the motorcycle. RAM&trade; and QuadLock&trade; mounts recommended.

## Usage
Pressing "Calibrate" sets a base position for the device and allows lean tracking of the device and ergo the motorcyle it is secured to. When a target lean angle is achieved (determined by the class of motorcycle selected in the settings menu) a countdown timer will begin.
This timer ranges between 10 and 60 seconds and can be changed by the user in the settings menu. If the device is not righted, or the user
does not press "Cancel" before the timer reaches 0, then a message containing the user's name and a descrition of their bike (entered in settings) and a description of their location will be sent to up to three contacts (also entered in settings). After this message is sent an alert will be presented asking the user if they would like to send an "OK" message. This sends and SMS to the user's contacts saying that the user has responded to Rubber Side Down. During use the user may press "End Ride" to reset the app and stop device motion updates.

[Screenshots available here](https://imgur.com/a/04EqyXt)


***IMPORTANT***

This version of Rubber Side Down does not include the Twilio authentication token need for authentication with the Twilio web api to 
send an SMS. A valid token may be added to the field TOKEN on line 21 of RubberSideDown/CrashEvent.swift. Without this token the app
will function normally, however no SMS will be sent when a crash is detected and the preset timer runs down. Uncomment the print statement
on line 105 of RubberSideDown/CrashEvent.swift to see a printout of the emergency messages that would be sent if the token was present.
