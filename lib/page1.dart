import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart'; // For donut chart
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:provider/provider.dart';
import 'ip_address_model.dart';

class Page1 extends StatefulWidget {
  const Page1({super.key});

  @override
  _Page1State createState() => _Page1State();
}

class _Page1State extends State<Page1> {
  WebSocketChannel? channel;
  double temperature = 0.0;
  double voltage = 0.0;

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

  @override
  Widget build(BuildContext context) {
    // Fetch the ESP32 IP address from IpAddressModel
    final esp32Ip = context.watch<IpAddressModel>().esp32Ip;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Page 6'),
      ),
      body: channel == null
          ? const Center(child: CircularProgressIndicator()) // Show a loading indicator while the WebSocket is initializing
          : StreamBuilder(
        stream: channel!.stream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            // Debugging: print the received data
            print('Received from ESP32: ${snapshot.data}');

            // Parse the data (assumed to be comma-separated: "temperature,voltage")
            var data = snapshot.data.toString().split(',');
            if (data.length == 2) {
              temperature = double.tryParse(data[0]) ?? 0.0;
              voltage = double.tryParse(data[1]) ?? 0.0;
            }

            // Debugging: print the parsed values
            print('Parsed temperature: $temperature');
            print('Parsed voltage: $voltage');
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Donut Chart representing temperature and voltage
                SizedBox(
                  height: 250,
                  child: Stack(
                    children: [
                      PieChart(
                        PieChartData(
                          startDegreeOffset: 250,
                          sectionsSpace: 0,
                          centerSpaceRadius: 100,
                          sections: [
                            PieChartSectionData(
                              value: temperature.clamp(0.0, 100.0),
                              color: Colors.greenAccent,
                              radius: 45,
                              showTitle: false,
                            ),
                            PieChartSectionData(
                              value: voltage.clamp(0.0, 5.0) * 20, // Scale voltage to fit the chart (e.g., max 5V)
                              color: Colors.blueAccent,
                              radius: 25,
                              showTitle: false,
                            ),
                            PieChartSectionData(
                              value: 100 - (temperature.clamp(0.0, 100.0) + voltage.clamp(0.0, 5.0) * 20),
                              color: Colors.grey.shade400,
                              radius: 20,
                              showTitle: false,
                            ),
                          ],
                        ),
                      ),
                      Positioned.fill(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              height: 160,
                              width: 160,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.shade200,
                                    blurRadius: 10.0,
                                    spreadRadius: 10.0,
                                    offset: const Offset(3.0, 3.0),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  "Temp: ${temperature.toStringAsFixed(2)}°C\nVoltage: ${voltage.toStringAsFixed(2)}V",
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    // Close the WebSocket channel when the page is disposed
    channel?.sink.close();
    super.dispose();
  }
}
