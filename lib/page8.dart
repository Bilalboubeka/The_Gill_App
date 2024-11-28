import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mjpeg/flutter_mjpeg.dart';
import 'dart:io';
import 'ip_address_model.dart';

class Page8 extends StatefulWidget {
  const Page8({super.key});

  @override
  _Page8State createState() => _Page8State();
}

class _Page8State extends State<Page8> {
  final List<double> sliderValues = [90.0, 0.0, 90.0, 90.0, 90.0, 90.0, 0.0];
  final List<Offset> sliderPositions = [
    const Offset(30, 10),
    const Offset(160, 290),
    const Offset(710, 10),
    const Offset(780, 10),
    const Offset(160, 235),
    const Offset(100, 10),
    const Offset(160, 350),
  ];
  final List<bool> sliderOrientations = [true, false, true, true, false, true, false];

  final double buttonSliderSpacing = 0; // Reduced spacing

  late RawDatagramSocket udpSocket;
  int esp32Port = 4210;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);

    udpSocketSetup();
  }

  void udpSocketSetup() async {
    udpSocket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
  }

  void sendSliderValue(int index, double value) {
    final esp32Ip = context.read<IpAddressModel>().esp32Ip;
    final message = 'S$index:${value.toStringAsFixed(4)}';
    udpSocket.send(message.codeUnits, InternetAddress(esp32Ip), esp32Port);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    udpSocket.close();
    super.dispose();
  }

  void adjustSliderValue(int index, double adjustment) {
    setState(() {
      double step = (index == 1 || index == 6) ? 0.2 : 1.0;
      sliderValues[index] = (sliderValues[index] + step * adjustment).clamp(
        (index == 1 || index == 6) ? -1.0 : 0.0,
        (index == 1 || index == 6) ? 1.0 : 180.0,
      );
      sendSliderValue(index, sliderValues[index]);
    });
  }

  @override
  Widget build(BuildContext context) {
    final esp32CamIp = context.watch<IpAddressModel>().esp32CamIp;

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            left: 290,
            top: 20,
            child: Container(
              width: 300,
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue),
                color: Colors.blue.withOpacity(0.3),
              ),
              child: Mjpeg(
                isLive: true,
                stream: 'http://$esp32CamIp:81/stream',
                timeout: const Duration(seconds: 5),
                error: (context, error, stack) {
                  return Center(child: Text('Error: $error'));
                },
              ),
            ),
          ),
          for (int i = 0; i < 7; i++)
            Positioned(
              left: sliderPositions[i].dx,
              top: sliderPositions[i].dy,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (sliderOrientations[i])
                    Padding(
                      padding: EdgeInsets.only(bottom: buttonSliderSpacing),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_drop_up),
                        onPressed: () => adjustSliderValue(i, 1.0),
                      ),
                    ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!sliderOrientations[i])
                        Padding(
                          padding: EdgeInsets.only(right: buttonSliderSpacing),
                          child: IconButton(
                            icon: const Icon(Icons.arrow_left),
                            onPressed: () => adjustSliderValue(i, -1.0),
                          ),
                        ),
                      SizedBox(
                        height: sliderOrientations[i] ? 300 : 60,
                        width: sliderOrientations[i] ? 60 : 450,
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 20),
                            trackHeight: 8,
                            activeTrackColor: (i == 1 || i == 6) ? Colors.blue : Colors.green,
                            inactiveTrackColor: (i == 1 || i == 6)
                                ? Colors.blue.withOpacity(0.3)
                                : Colors.green.withOpacity(0.3),
                          ),
                          child: sliderOrientations[i]
                              ? RotatedBox(
                            quarterTurns: 1,
                            child: Slider(
                              value: sliderValues[i],
                              min: (i == 1 || i == 6) ? -1 : 0,
                              max: (i == 1 || i == 6) ? 1 : 180,
                              onChanged: (value) {
                                setState(() => sliderValues[i] = value);
                                sendSliderValue(i, value);
                              },
                              onChangeEnd: (value) {
                                if (i == 1 || i == 6) {
                                  setState(() => sliderValues[i] = 0.0);
                                  sendSliderValue(i, 0.0);
                                }
                              },
                              activeColor: (i == 1 || i == 6) ? Colors.blue : Colors.green,
                            ),
                          )
                              : Slider(
                            value: sliderValues[i],
                            min: (i == 1 || i == 6) ? -1 : 0,
                            max: (i == 1 || i == 6) ? 1 : 180,
                            onChanged: (value) {
                              setState(() => sliderValues[i] = value);
                              sendSliderValue(i, value);
                            },
                            onChangeEnd: (value) {
                              if (i == 1 || i == 6) {
                                setState(() => sliderValues[i] = 0.0);
                                sendSliderValue(i, 0.0);
                              }
                            },
                            activeColor: (i == 1 || i == 6) ? Colors.blue : Colors.green,
                          ),
                        ),
                      ),
                      if (!sliderOrientations[i])
                        Padding(
                          padding: EdgeInsets.only(left: buttonSliderSpacing),
                          child: IconButton(
                            icon: const Icon(Icons.arrow_right),
                            onPressed: () => adjustSliderValue(i, 1.0),
                          ),
                        ),
                    ],
                  ),
                  if (sliderOrientations[i])
                    Padding(
                      padding: EdgeInsets.only(top: buttonSliderSpacing),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_drop_down),
                        onPressed: () => adjustSliderValue(i, -1.0),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
