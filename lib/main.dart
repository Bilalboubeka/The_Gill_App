import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_cube/flutter_cube.dart'; // Import the flutter_cube package
import 'splash_screen.dart';
import 'page1.dart';
import 'page2.dart';
import 'page3.dart';
import 'page4.dart';
import 'page5.dart';
import 'page6.dart';
import 'page7.dart';
import 'page8.dart';
import 'ip_address_model.dart';  // Import your IpAddressModel class

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => IpAddressModel(), // Provide the IpAddressModel
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'TheGill',
          style: TextStyle(
            fontSize: 30.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          // 3D Model SizedBox
          SizedBox(
            height: 300.0, // Adjust the height as needed
            child: Cube(
              onSceneCreated: (Scene scene) {
                final model = Object(fileName: 'assets/3d_model/cat/12221_Cat_v1_l3.obj');
                scene.world.add(model);
                scene.camera.zoom = 10; // Adjust the zoom level
                scene.camera.position.setValues(0, 0, 10); // Adjust the camera position
              },
            ),
          ),
          // Spacing between the model and the buttons
          const SizedBox(height: 16.0),
          // Grid of Buttons
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // 2 buttons per row
                  crossAxisSpacing: 16.0, // Space between columns
                  mainAxisSpacing: 16.0, // Space between rows
                  childAspectRatio: 2, // Aspect ratio to make the buttons rectangular
                ),
                itemCount: 8, // Number of buttons
                itemBuilder: (context, index) {
                  // Define button names
                  final buttonNames = [
                    'Battery',
                    'Control',
                    'Motors',
                    'IP',
                    'Page 5',
                    'Page 6',
                    'Page 7',
                    'Page 8',
                  ];

                  final pages = [
                    const Page1(),
                    const Page2(),
                    const Page3(),
                    const Page4(),
                    const Page5(),
                    const Page6(),
                    const Page7(),
                    const Page8(),
                  ];

                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green, // Green background
                    ),
                    onPressed: () {
                      // Navigate to the corresponding page
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => pages[index]),
                      );
                    },
                    child: Text(
                      buttonNames[index],
                      style: const TextStyle(
                        fontSize: 29.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
