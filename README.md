#SMS Sender

A simple Android app to send sms from an embedded web server.

## Description
This simple app has been developed in Flutter and use another custom plugin that wraps the Android
SMS API.

Beware: the use of this app is forbidden by the Play Store rules.

## How to use
* Launch the App
* Grant the "Send SMS" permission when requested
* Note the URL displayed in the interface

* You can now connect to the http interface and send SMS using the simple web page displayed or
 you can call directly the Rest API making a POST request:

 <pre>
 curl -X POST --data '{"message":"Hello from a script through Android", "number":"1234566778"}' http://192.168.1.122:4567/send
 </pre>

#### App Icon Credit
SMS by Arafat Uddin from the Noun Project
https://thenounproject.com/search/?q=sms&i=860316#