import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_joystick/flutter_joystick.dart';
import 'package:flutter_mjpeg/flutter_mjpeg.dart';
import 'package:provider/provider.dart';
import 'ip_address_model.dart';
import 'page8.dart'; // Import Page5

class Page2 extends StatefulWidget {
  const Page2({super.key});

  @override
  _Page2State createState() => _Page2State();
}

class _Page2State extends State<Page2> {
  // Initial positions of the joysticks
  Offset joystick1Position = const Offset(80, 80);
  Offset joystick2Position = const Offset(660, 80);

  // Rectangle dimensions and position
  final Offset rectanglePosition = const Offset(320, 80);
  final double rectangleWidth = 300;
  final double rectangleHeight = 200;

  // Button positions
  Offset button1Position = const Offset(120, 10);
  Offset button2Position = const Offset(700, 10);

  // Slider values and positions
  double slider1Value = 0.0;
  double slider2Value = 0.0;
  double slider3Value = 0.0;

  Offset slider1Position = const Offset(85, 300);
  Offset slider2Position = const Offset(400, 300);
  Offset slider3Position = const Offset(700, 300);

  // Switch button states, sizes, and positions
  bool switch1State = false;
  bool switch2State = false;
  bool switch3State = false;
  bool switch4State = false;
  bool switch5State = false;

  Offset switch1Position = const Offset(225, 10);
  Offset switch2Position = const Offset(325, 10);
  Offset switch3Position = const Offset(425, 10);
  Offset switch4Position = const Offset(525, 10);
  Offset switch5Position = const Offset(625, 10);

  double switchWidth = 50.0;
  double switchHeight = 30.0;

  // UDP Socket for sending data
  RawDatagramSocket? udpSocket;

  @override
  void initState() {
    super.initState();

    // Force landscape orientation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    _initializeUdpSocket();
  }

  @override
  void dispose() {
    // Reset to default orientation when leaving the page
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    udpSocket?.close();
    super.dispose();
  }

  // Initialize UDP socket
  void _initializeUdpSocket() async {
    udpSocket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
    udpSocket?.listen((event) {
      // Handle incoming UDP data (if needed)
    });
  }

  // Send data via UDP
  void _sendData(String message, String esp32Ip, int esp32Port) {
    udpSocket?.send(message.codeUnits, InternetAddress(esp32Ip), esp32Port);
    print("Sent: $message to $esp32Ip:$esp32Port");
  }

  @override
  Widget build(BuildContext context) {
    // Fetch the IP addresses from the IpAddressModel
    final esp32Ip = context.watch<IpAddressModel>().esp32Ip;
    final esp32CamIp = context.watch<IpAddressModel>().esp32CamIp;
    const esp32Port = 4210; // Replace with your ESP32 UDP port if needed

    return Scaffold(
      appBar: AppBar(
        title: const Text('Controls'),
      ),
      body: GestureDetector(
        onVerticalDragUpdate: (details) {
          if (details.primaryDelta! < -20) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Page8()),
            );
          }
        },
        child: Stack(
          children: [
            // Joystick 1
            Positioned(
              left: joystick1Position.dx,
              top: joystick1Position.dy,
              child: Joystick(
                base: JoystickBase(
                  decoration: JoystickBaseDecoration(
                    middleCircleColor: Colors.green.shade400,
                    drawOuterCircle: false,
                    drawInnerCircle: false,
                    boxShadowColor: Colors.green.shade100,
                  ),
                  arrowsDecoration: JoystickArrowsDecoration(
                    color: Colors.green,
                  ),
                  mode: JoystickMode.vertical,
                ),
                listener: (details) {
                  double yValue = -details.y.clamp(-1.0, 1.0);
                  _sendData('J1:${yValue.toStringAsFixed(4)}', esp32Ip, esp32Port);
                },
              ),
            ),
            // Joystick 2
            Positioned(
              left: joystick2Position.dx,
              top: joystick2Position.dy,
              child: Joystick(
                base: JoystickBase(
                  decoration: JoystickBaseDecoration(
                    middleCircleColor: Colors.green.shade400,
                    drawOuterCircle: false,
                    drawInnerCircle: false,
                    boxShadowColor: Colors.green.shade100,
                  ),
                  arrowsDecoration: JoystickArrowsDecoration(
                    color: Colors.green,
                  ),
                  mode: JoystickMode.horizontal,
                ),
                listener: (details) {
                  String message = 'J2:${details.x.toStringAsFixed(4)}';
                  _sendData(message, esp32Ip, esp32Port);
                },
              ),
            ),
            // Rectangle (Video Stream Screen)
            Positioned(
              left: rectanglePosition.dx,
              top: rectanglePosition.dy,
              child: Container(
                width: rectangleWidth,
                height: rectangleHeight,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue),
                  color: Colors.blue.withOpacity(0.3),
                ),
                child: Mjpeg(
                  isLive: true,
                  stream: 'http://$esp32CamIp:81/stream',
                  timeout: const Duration(seconds: 5),
                  error: (context, error, stack) {
                    return Center(
                      child: Text('Error: $error'),
                    );
                  },
                ),
              ),
            ),
            // Existing Buttons and Sliders
            _buildButton(button1Position, 'Button 1', esp32Ip, esp32Port),
            _buildButton(button2Position, 'Button 2', esp32Ip, esp32Port),
            _buildSlider(slider1Position, slider1Value, 'Slider1', esp32Ip, esp32Port, (value) {
              setState(() => slider1Value = value);
            }),
            _buildSlider(slider2Position, slider2Value, 'Slider2', esp32Ip, esp32Port, (value) {
              setState(() => slider2Value = value);
            }),
            _buildSlider(slider3Position, slider3Value, 'Slider3', esp32Ip, esp32Port, (value) {
              setState(() => slider3Value = value);
            }),
            // Switch Buttons with Color Change
            _buildSwitchButton(switch1Position, 'Switch1', switch1State, esp32Ip, esp32Port, (state) {
              setState(() => switch1State = state);
            }),
            _buildSwitchButton(switch2Position, 'Switch2', switch2State, esp32Ip, esp32Port, (state) {
              setState(() => switch2State = state);
            }),
            _buildSwitchButton(switch3Position, 'Switch3', switch3State, esp32Ip, esp32Port, (state) {
              setState(() => switch3State = state);
            }),
            _buildSwitchButton(switch4Position, 'Switch4', switch4State, esp32Ip, esp32Port, (state) {
              setState(() => switch4State = state);
            }),
            _buildSwitchButton(switch5Position, 'Switch5', switch5State, esp32Ip, esp32Port, (state) {
              setState(() => switch5State = state);
            }),
          ],
        ),
      ),
    );
  }

  // Helper method to create a button
  Widget _buildButton(Offset position, String label, String esp32Ip, int esp32Port) {
    return Positioned(
      left: position.dx,
      top: position.dy,
      child: ElevatedButton(
        onPressed: () {
          String message = '$label ';
          _sendData(message, esp32Ip, esp32Port);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green.shade300,
          shadowColor: Colors.green.shade800,
        ),
        child: Text(label),
      ),
    );
  }

  // Helper method to create a slider
  Widget _buildSlider(Offset position, double value, String label, String esp32Ip, int esp32Port, ValueChanged<double> onChanged) {
    return Positioned(
      left: position.dx,
      top: position.dy,
      child: SliderTheme(
        data: const SliderThemeData(
          activeTrackColor: Colors.green,
          thumbColor: Colors.green,
        ),
        child: Slider(
          value: value,
          min: 0.0,
          max: 100.0,
          onChanged: (value) {
            onChanged(value);
            String message = '$label:${value.toStringAsFixed(1)}';
            _sendData(message, esp32Ip, esp32Port);
          },
        ),
      ),
    );
  }

  // Helper method to create a switch button
  Widget _buildSwitchButton(Offset position, String label, bool value, String esp32Ip, int esp32Port, ValueChanged<bool> onChanged) {
    return Positioned(
      left: position.dx,
      top: position.dy,
      child: Transform.scale(
        scale: 1.2,
        child: Switch(
          value: value,
          onChanged: (state) {
            onChanged(state);
            String message = '$label:${state ? "ON" : "OFF"}';
            _sendData(message, esp32Ip, esp32Port);
          },
          activeColor: Colors.green,
          inactiveThumbColor: Colors.blue,
        ),
      ),
    );
  }
}
