import 'package:flutter/material.dart';

class IpAddressModel extends ChangeNotifier {
  String _esp32Ip = '';
  String _esp32CamIp = '';

  String get esp32Ip => _esp32Ip;
  String get esp32CamIp => _esp32CamIp;

  void setEsp32Ip(String ip) {
    _esp32Ip = ip;
    notifyListeners();
  }

  void setEsp32CamIp(String ip) {
    _esp32CamIp = ip;
    notifyListeners();
  }
}