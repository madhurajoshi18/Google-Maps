import 'dart:typed_data';
import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';

class CurrentLocationScreen extends StatefulWidget {
  const CurrentLocationScreen({Key? key}) : super(key: key);

  @override
  _CurrentLocationScreenState createState() => _CurrentLocationScreenState();
}

class _CurrentLocationScreenState extends State<CurrentLocationScreen> {
  late GoogleMapController googleMapController;
  static const CameraPosition initialCameraPosition = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14,
  );

  Set<Marker> markers = {};
  Marker? currentLocationMarker;
  String placeName = '';

  LatLng currentMarkerPosition = LatLng(37.42796133580664, -122.085749655962);

  @override
  void initState() {
    super.initState();
    loadMarkers();
  }

  Future<void> loadMarkers() async {
    final bikeIcon = await _loadBitmapDescriptor('assets/bike_icon.png');
    final carIcon = await _loadBitmapDescriptor('assets/car_icon.png');
    final walkingIcon = await _loadBitmapDescriptor('assets/walking_icon.png');

    setState(() {
      markers = {
        Marker(
          markerId: const MarkerId('bike'),
          position: LatLng(37.7749, -122.4194),
          icon: BitmapDescriptor.fromBytes(bikeIcon),
        ),
        Marker(
          markerId: const MarkerId('car'),
          position: LatLng(37.7895, -122.4144),
          icon: BitmapDescriptor.fromBytes(carIcon),
        ),
        Marker(
          markerId: const MarkerId('walking'),
          position: LatLng(37.7814, -122.4460),
          icon: BitmapDescriptor.fromBytes(walkingIcon),
        ),
      };
    });

    addCurrentLocationMarker();
  }

  Future<Uint8List> _loadBitmapDescriptor(String imagePath) async {
    final ByteData byteData = await rootBundle.load(imagePath);
    final Uint8List bytes = byteData.buffer.asUint8List();
    return bytes;
  }

  void addCurrentLocationMarker() async {
    Position position = await _determinePosition();
    placeName = await _getPlaceName(position.latitude, position.longitude);

    currentLocationMarker = Marker(
      markerId: const MarkerId('currentLocation'),
      position: LatLng(position.latitude, position.longitude),
      infoWindow: InfoWindow(
        title: 'Current Location',
        snippet: placeName,
      ),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      draggable: true,
      onDragEnd: (newPosition) {
        updateCurrentMarkerPosition(newPosition);
      },
    );

    setState(() {
      markers.add(currentLocationMarker!);
    });
  }

  void updateCurrentMarkerPosition(LatLng position) async {
    placeName = await _getPlaceName(position.latitude, position.longitude);

    setState(() {
      markers.remove(currentLocationMarker);

      currentLocationMarker = Marker(
        markerId: const MarkerId('currentLocation'),
        position: position,
        infoWindow: InfoWindow(
          title: 'Current Location',
          snippet: placeName,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        draggable: true,
        onDragEnd: (newPosition) {
          updateCurrentMarkerPosition(newPosition);
        },
      );

      markers.add(currentLocationMarker!);
    });
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return Future.error(
            'Location permissions are denied (actual value: $permission).');
      }
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<String> _getPlaceName(double latitude, double longitude) async {
    List<Placemark> placemarks =
        await placemarkFromCoordinates(latitude, longitude);

    if (placemarks.isNotEmpty) {
      Placemark placemark = placemarks[0];
      return '${placemark.name}, ${placemark.locality}, ${placemark.administrativeArea}';
    }

    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Current Location Screen'),
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (controller) {
              googleMapController = controller;
            },
            initialCameraPosition: initialCameraPosition,
            markers: markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
          ),
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Place: $placeName',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
