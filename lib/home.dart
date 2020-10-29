
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sms_sender/embedded-server.dart';
import 'package:screen_keep_on/screen_keep_on.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  EmbeddedServer server = EmbeddedServer();
  String message;


  HomePageState() {
    // Initialize the web server
    this._init();
    // Set Keep Screen On
    ScreenKeepOn.turnOn(true);
    }

  void _init() async{
    await server.initWebServer();
      if (this.mounted) {
        setState(() {

        });
      }
      // Subscribe to the stream from WebServer
     this.server.messages.listen((event) {
       print("Message received: ${event.message}");
       setState(() {
         message = event.message;
       });
     });
    }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('\n\nListening at http://${server?.serverInfo?.wifiIP}:${server?.serverInfo?.port}',
                style: TextStyle(fontWeight: FontWeight.bold)),
            message != null
                ? Text('\n$message')
                : Text('\n'),
        Padding(
          padding: EdgeInsets.symmetric(horizontal:40.0),
          child: Text('\n\n\nOpen the above http address with your browser or use something like curl to send sms remotely.\n\n'
              '\n\nThe API is just a single POST with a JSON object with a number and message fields\n',
            textAlign: TextAlign.center,)
        ),
        Padding(
            padding: EdgeInsets.symmetric(horizontal:50.0),
            child:Text('curl -X POST --data \'{"message":"Hello from a script", "number":"1234566778"}\' http://${server?.serverInfo?.wifiIP}:${server?.serverInfo?.port}/send',
                 textScaleFactor: 0.9)
        ),
          Flexible(child:Align(
            alignment: Alignment.bottomCenter,
            child: Text('Developed by Stefano Falda 2020', textScaleFactor: 0.8,))
          )
          ]
        ),
    );
  }
}