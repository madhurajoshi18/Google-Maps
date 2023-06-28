import 'package:flutter/material.dart';
import 'package:google_maps_demo/current_location_screen.dart';
import 'package:google_maps_demo/custom_marker_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Flutter Google Maps"),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'Welcome to the Home Screen!',
          style: TextStyle(fontSize: 24),
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CurrentLocationScreen(),
                ),
              );
            },
            label: const Text("Go to Current Location"),
            icon: const Icon(Icons.location_on),
          ),
          const SizedBox(height: 16),
          FloatingActionButton.extended(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CustomMarkerScreen(),
                ),
              );
            },
            label: const Text("Go to Custom Markers"),
            icon: const Icon(Icons.map),
          ),
        ],
      ),
    );
  }
}
