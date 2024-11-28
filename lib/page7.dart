import 'dart:math';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';

class Page7 extends StatefulWidget {
  const Page7({super.key});

  @override
  _Page7State createState() => _Page7State();
}

class _Page7State extends State<Page7> {
  late Anchor arm;
  late RawDatagramSocket udpSocket;
  final String esp32Ip = '4.4.4.100'; // Replace with your ESP32's IP address
  final int esp32Port = 4210; // Replace with your ESP32's UDP port

  @override
  void initState() {
    super.initState();
    _setupUDP();
    _initializeArms();
  }

  void _setupUDP() async {
    udpSocket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
  }

  void _sendJointAngles() {
    final angles = {
      'joint1': arm.child!.angle,
      'joint2': arm.child!.child!.angle,
      'joint3': arm.child!.child!.child!.angle,
    };
    final message = jsonEncode(angles);
    udpSocket.send(
      utf8.encode(message),
      InternetAddress(esp32Ip),
      esp32Port,
    );
  }

  void _initializeArms() {
    arm = Anchor(loc: const Offset(200, 200));
    Bone b1 = Bone(100.0, arm);
    arm.child = b1;
    Bone b2 = Bone(100.0, b1);
    b1.child = b2;
    Bone b3 = Bone(100.0, b2);
    b2.child = b3;
  }

  void _updateJoint1(double angle) {
    setState(() {
      arm.child!.angle = angle;
      _sendJointAngles();
    });
  }

  void _updateJoint2(double angle) {
    setState(() {
      arm.child!.child!.angle = angle;
      _sendJointAngles();
    });
  }

  void _updateJoint3(double angle) {
    setState(() {
      arm.child!.child!.child!.angle = angle;
      _sendJointAngles();
    });
  }

  @override
  void dispose() {
    udpSocket.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('3-Bone IK Control'),
      ),
      body: Column(
        children: [
          Slider(
            value: arm.child!.angle,
            min: -pi / 2,
            max: pi / 2,
            onChanged: _updateJoint1,
            label: 'Joint 1',
          ),
          Slider(
            value: arm.child!.child!.angle,
            min: -pi / 2,
            max: pi / 2,
            onChanged: _updateJoint2,
            label: 'Joint 2',
          ),
          Slider(
            value: arm.child!.child!.child!.angle,
            min: -pi / 2,
            max: pi / 2,
            onChanged: _updateJoint3,
            label: 'Joint 3',
          ),
          Expanded(
            child: CustomPaint(
              painter: ArmPainter(arm),
              child: Container(),
            ),
          ),
        ],
      ),
    );
  }
}

class Anchor {
  Offset loc;
  Bone? child;

  Anchor({required this.loc});

  void solve(Offset target) {
    child?.solve(target);
  }
}

class Bone {
  double length;
  double angle = 0;
  Bone? child;
  dynamic parent;

  Bone(this.length, this.parent);

  Offset get parentLoc {
    if (parent is Anchor) {
      return (parent as Anchor).loc;
    } else if (parent is Bone) {
      return (parent as Bone).getEnd();
    } else {
      throw Exception('Invalid parent type');
    }
  }

  void solve(Offset target) {
    if (child != null) {
      child!.solve(target);
      target = child!.getEnd();
    }
    angle = atan2(target.dy - parentLoc.dy, target.dx - parentLoc.dx);
  }

  Offset getEnd() {
    return Offset(
      parentLoc.dx + cos(angle) * length,
      parentLoc.dy + sin(angle) * length,
    );
  }
}

class ArmPainter extends CustomPainter {
  final Anchor arm;

  ArmPainter(this.arm);

  @override
  void paint(Canvas canvas, Size size) {
    _drawBone(canvas, arm.child!);
  }

  void _drawBone(Canvas canvas, Bone bone) {
    final paint = Paint()
      ..color = Colors.greenAccent
      ..strokeWidth = 9.0
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(bone.parentLoc, bone.getEnd(), paint);

    if (bone.child != null) {
      _drawBone(canvas, bone.child!);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
