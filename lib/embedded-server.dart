import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/services.dart';
import 'package:sms_auto_sender/sms_auto_sender.dart';

class ServerInfo{
  String wifiIP;
  int port = 4567;
}

enum EventsType {
  ShouldRequestPermission,
  MessageSent,
  MessageError
}

class ServerEvents{
  EventsType type;
  String message;

  ServerEvents(EventsType type, String message){
    this.type = type;
    this.message = message;
  }
}

class EmbeddedServer{
  ServerInfo serverInfo = ServerInfo();
  StreamController<ServerEvents> _controller = StreamController<ServerEvents>();
  Stream messages;


  Future<ServerInfo> initWebServer() async {
    messages = _controller.stream;
    serverInfo.wifiIP = await (Connectivity().getWifiIP());
    // Check if the device can send message
    bool canSend = await SmsAutoSender.canSendSMS();
    if (!canSend){
      _controller.add(ServerEvents(EventsType.MessageError, "Current device cannot send SMS"));
    }
    bool hasPermissionToSendSMS = await SmsAutoSender.hasPermissionToSendSMS();
    if (!hasPermissionToSendSMS){
      await SmsAutoSender.requestPermissionToSendSMS();
      _controller.add(ServerEvents(EventsType.ShouldRequestPermission, "You have to grant the authorization to send SMS"));
    }


    //Check if the sms has been
    print("Listening at ${serverInfo.wifiIP} on port ${serverInfo.port}");
    //_controller.add(ServerEvents(EventsType.MessageSent,"Listening at ${serverInfo.wifiIP} on port ${serverInfo.port}"));
    HttpServer.bind(InternetAddress.anyIPv4, serverInfo.port).then((server) {
      server.listen((HttpRequest request) {
        switch (request.method) {
          case 'GET':
            handleGetRequest(request);
            break;
          case 'POST':
            handlePostRequest(request);
            break;
        }
      }, onError: handleError); // listen() failed.
    }).catchError(handleError);

    return this.serverInfo;
  }

  void handleGetRequest(HttpRequest request) async {
    //print('Connection from '
    //        '${request.headers. .remoteAddress.address}:${client.remotePort}');
    // print('Parameters: ${client.stream}');
    HttpResponse res = request.response;
    res.statusCode = HttpStatus.ok;
    res.headers.contentType = ContentType.parse("text/html");

    String fileText = await rootBundle.loadString('assets/www/index.html');
    res.write(fileText);
    //res.write('Received request ${request.method}: ${request.uri.path}');
    res.close();
  }

  void handlePostRequest(HttpRequest request) async {
    HttpResponse res = request.response;
    try {
      String content = await utf8.decoder.bind(request).join();
      var data = jsonDecode(content) as Map;

      print("number: ${data["number"]}");
      print("message: ${data["message"]}");
      // Invia il messaggio SMS
      String phone = data["number"];
      String message = data["message"];

      _sendSMS(message, [phone]);
      _controller.add(ServerEvents(EventsType.MessageSent, "Message sent to $phone"));
      res.write('Message sent to  $phone');
    } finally {
      res.close();
    }
  }

  void handleError(err) {
    print("Error: $err");
  }

  void _sendSMS(String message, List<String> recipents) async {
    bool _result = await SmsAutoSender.sendSMS(message: message, recipients: recipents)
        .catchError((onError) {
    });
    print(_result);
  }

}