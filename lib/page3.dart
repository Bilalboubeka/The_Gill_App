import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'ip_address_model.dart'; // Import the IpAddressModel

class Page3 extends StatefulWidget {
  const Page3({super.key});

  @override
  _Page3State createState() => _Page3State();
}

class _Page3State extends State<Page3> {
  WebSocketChannel? channel;

  // Store motor statuses
  String motor1Status = 'Waiting...';
  String motor2Status = 'Waiting...';
  String motor3Status = 'Waiting...';
  String motor4Status = 'Waiting...';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final esp32Ip = context.read<IpAddressModel>().esp32Ip;
      _initializeWebSocket(esp32Ip);
    });
  }

  void _initializeWebSocket(String esp32Ip) {
    setState(() {
      // Create a WebSocket channel using the saved ESP32 IP address
      channel = WebSocketChannel.connect(
        Uri.parse('ws://$esp32Ip:81'), // Replace with your ESP32 WebSocket port
      );
    });
  }

  void sendTestCommand() {
    // Send a test command to ESP32 via WebSocket
    channel?.sink.add('TEST_MOTORS');
    setState(() {
      // Reset statuses to indicate that testing is in progress
      motor1Status = 'Testing...';
      motor2Status = 'Testing...';
      motor3Status = 'Testing...';
      motor4Status = 'Testing...';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Motor Test Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: sendTestCommand,
              child: const Text('Test Motors'),
            ),
            const SizedBox(height: 20),
            channel == null
                ? const CircularProgressIndicator() // Show a loading indicator while the WebSocket is initializing
                : StreamBuilder(
              stream: channel!.stream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  // Received data from ESP32
                  String message = snapshot.data.toString();
                  // Parse the status for each motor (assuming ESP32 sends "MOTORx:OK" or "MOTORx:FAIL")
                  if (message.startsWith('MOTOR1:')) {
                    motor1Status = message;
                  } else if (message.startsWith('MOTOR2:')) {
                    motor2Status = message;
                  } else if (message.startsWith('MOTOR3:')) {
                    motor3Status = message;
                  } else if (message.startsWith('MOTOR4:')) {
                    motor4Status = message;
                  }
                }
                return Column(
                  children: [
                    StatusTile(motorNumber: 1, status: motor1Status),
                    StatusTile(motorNumber: 2, status: motor2Status),
                    StatusTile(motorNumber: 3, status: motor3Status),
                    StatusTile(motorNumber: 4, status: motor4Status),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Close the WebSocket connection when the page is disposed
    channel?.sink.close();
    super.dispose();
  }
}

class StatusTile extends StatelessWidget {
  final int motorNumber;
  final String status;

  const StatusTile({required this.motorNumber, required this.status, super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text('Motor $motorNumber Status:'),
      subtitle: Text(status),
    );
  }
}
