import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:udp/udp.dart';
import 'dart:io';
import 'ip_address_model.dart';

class Page5 extends StatefulWidget {
  const Page5({super.key});

  @override
  _Page5State createState() => _Page5State();
}

class _Page5State extends State<Page5> {
  List<double> _sliderPositions = [0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5];
  late UDP _udp;
  final int esp32Port = 4210;
  final double sliderHeight = 300.0; // Define a fixed height for sliders
  final double circleDiameter = 60.0; // Define the diameter for the slider button

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    _initializeUdp();
  }

  void _initializeUdp() async {
    _udp = await UDP.bind(Endpoint.any());
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    _udp.close();
    super.dispose();
  }

  void _sendData(String data) async {
    final esp32Ip = context.read<IpAddressModel>().esp32Ip;
    if (esp32Ip.isNotEmpty) {
      final endpoint = Endpoint.unicast(InternetAddress(esp32Ip), port: Port(esp32Port));
      await _udp.send(data.codeUnits, endpoint);
      print('Sent data: $data to $esp32Ip:$esp32Port');
    }
  }

  void _onSliderUpdate(int index, DragUpdateDetails details) {
    setState(() {
      _sliderPositions[index] += details.delta.dy / sliderHeight;
      _sliderPositions[index] = _sliderPositions[index].clamp(0.0, 1.0);

      double value;
      if (index == 1 || index == 6) {
        // Green sliders: -1 at the bottom, 1 at the top
        value = 1 - (_sliderPositions[index] * 2);
      } else {
        // Purple sliders: 180 at the top, 0 at the bottom
        value = 180 * (1 - _sliderPositions[index]);
      }
      _sendData('S$index:${value.toStringAsFixed(4)}');
    });
  }

  void _onSliderEnd(DragEndDetails details, int index) {
    setState(() {
      _sliderPositions[index] = 0.5;
      _sendData('S$index:0.0');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ARM Control'),
      ),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(7, (index) {
          return GestureDetector(
            onVerticalDragUpdate: (details) => _onSliderUpdate(index, details),
            onVerticalDragEnd: index == 1 || index == 6
                ? (details) => _onSliderEnd(details, index)
                : null,
            child: _buildSlider(
              index,
              index == 1 || index == 6 ? Colors.green : Colors.blue,
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSlider(int index, Color color) {
    return Container(
      margin: const EdgeInsets.all(10),
      width: 60,
      height: sliderHeight,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary.withOpacity(0.5),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Positioned(
            top: _sliderPositions[index] * (sliderHeight - circleDiameter),
            child: Container(
              width: circleDiameter,
              height: circleDiameter,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(circleDiameter / 2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => IpAddressModel(),
      child: const MaterialApp(
        home: Page5(),
      ),
    ),
  );
}
