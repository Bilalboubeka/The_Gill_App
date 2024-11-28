import 'dart:async';
import 'dart:io';
import 'dart:math'; // Import dart:math for generating random messages
import 'package:flutter/material.dart';

class Page6 extends StatefulWidget {
  const Page6({super.key});

  @override
  _Page6State createState() => _Page6State();
}

class _Page6State extends State<Page6> {
  String udpData = 'Waiting for data...';
  RawDatagramSocket? _udpSocket;
  final int udpPort = 4210;

  @override
  void initState() {
    super.initState();
    startListeningForUDP();
    sendRandomUdpMessage(); // Send a random message when the page is opened
  }

  @override
  void dispose() {
    _udpSocket?.close();
    super.dispose();
  }

  void sendUdpData(String message) async {
    final address = InternetAddress('4.4.4.100'); // ESP32 IP address
    RawDatagramSocket.bind(InternetAddress.anyIPv4, 0).then((RawDatagramSocket socket) {
      socket.send(message.codeUnits, address, udpPort);
      print('Sent UDP message: $message');
    });
  }

  void sendRandomUdpMessage() {
    const randomMessage = 'Random message';
    sendUdpData(randomMessage);
  }

  void startListeningForUDP() async {
    try {
      _udpSocket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, udpPort);
      _udpSocket?.listen((RawSocketEvent event) {
        if (event == RawSocketEvent.read) {
          Datagram? dg = _udpSocket?.receive();
          if (dg != null) {
            String receivedMessage = String.fromCharCodes(dg.data);
            setState(() {
              udpData = receivedMessage;
            });
            print('Received UDP data: $receivedMessage');
          }
        }
      });

    } catch (e) {
      print('Error setting up UDP listener: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Page 6'),
      ),
      body: Center(
        child: Text(
          udpData,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
