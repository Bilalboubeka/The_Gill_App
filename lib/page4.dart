import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ip_address_model.dart';

class Page4 extends StatefulWidget {
  const Page4({super.key});

  @override
  _Page4State createState() => _Page4State();
}

class _Page4State extends State<Page4> {
  final _formKey = GlobalKey<FormBuilderState>();
  final _esp32IpController = TextEditingController();
  final _esp32CamIpController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSavedIps();
  }

  _loadSavedIps() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _esp32IpController.text = prefs.getString('esp32Ip') ?? '';
    _esp32CamIpController.text = prefs.getString('esp32CamIp') ?? '';
  }

  _saveIps(String esp32Ip, String esp32CamIp) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('esp32Ip', esp32Ip);
    prefs.setString('esp32CamIp', esp32CamIp);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Change IP Addresses'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FormBuilder(
          key: _formKey,
          child: Column(
            children: [
              FormBuilderTextField(
                name: 'esp32Ip',
                controller: _esp32IpController,
                decoration:const InputDecoration(
                  labelText: 'ESP32 IP Address',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              FormBuilderTextField(
                name: 'esp32CamIp',
                controller: _esp32CamIpController,
                decoration: const InputDecoration(
                  labelText: 'ESP32 Cam IP Address',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.saveAndValidate() ?? false) {
                    final esp32Ip = _esp32IpController.text;
                    final esp32CamIp = _esp32CamIpController.text;

                    Provider.of<IpAddressModel>(context, listen: false).setEsp32Ip(esp32Ip);
                    Provider.of<IpAddressModel>(context, listen: false).setEsp32CamIp(esp32CamIp);


                    _saveIps(esp32Ip, esp32CamIp);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('IP Addresses Updated')),
                    );

                    Navigator.pop(context);
                  }
                },
                child: const Text('Save'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
