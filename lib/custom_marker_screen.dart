import 'dart:typed_data';
import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CustomMarkerScreen extends StatefulWidget {
  const CustomMarkerScreen({Key? key}) : super(key: key);

  @override
  _CustomMarkerScreenState createState() => _CustomMarkerScreenState();
}

class _CustomMarkerScreenState extends State<CustomMarkerScreen> {
  final Completer<GoogleMapController> _controller = Completer();

  List<String> images = [
    'assets/bike_icon.png',
    'assets/car_icon.png',
    'assets/walking_icon.png',
    'assets/bike_icon.png',
    'assets/car_icon.png',
    'assets/walking_icon.png',
  ];

  List<Uint8List> markerImages = [];

  final List<Marker> _markers = <Marker>[];
  final List<LatLng> _latLng = <LatLng>[
    LatLng(15.496777, 73.827827),
    LatLng(28.644800, 77.216721),
    LatLng(19.076090, 72.877426),
    LatLng(22.572645, 88.363892),
    LatLng(12.972442, 77.580643),
    LatLng(31.633980, 74.872261),
  ];

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(19.663280, 75.300293),
    zoom: 15,
  );

  int? selectedMarkerIndex;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  loadData() async {
    for (int i = 0; i < images.length; i++) {
      final Uint8List markerIcon =
          await getBytesFromAsset(images[i].toString(), 100);
      markerImages.add(markerIcon);
      _markers.add(
        Marker(
          markerId: MarkerId(i.toString()),
          position: _latLng[i],
          icon: BitmapDescriptor.fromBytes(markerIcon),
          onTap: () {
            setState(() {
              selectedMarkerIndex = i;
            });
          },
          infoWindow: InfoWindow(
            title: "Marker $i",
            snippet: 'This is ${images[i]}',
          ),
        ),
      );
    }
    setState(() {});
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
      targetWidth: width,
    );
    ui.FrameInfo frameInfo = await codec.getNextFrame();
    return (await frameInfo.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  Widget buildInfoWidget(String text) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            offset: Offset(0, 2),
            blurRadius: 6,
          ),
        ],
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Custom Marker'),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: _kGooglePlex,
              mapType: MapType.normal,
              myLocationButtonEnabled: true,
              myLocationEnabled: true,
              markers: Set<Marker>.of(_markers),
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
            ),
            if (selectedMarkerIndex != null)
              Positioned(
                top: 16,
                left: 16,
                right: 16,
                child: buildInfoWidget('Marker $selectedMarkerIndex'),
              ),
          ],
        ),
      ),
    );
  }
}
