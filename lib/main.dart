import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Scaffold(
        bottomNavigationBar: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.adb), label: "adb"),
            BottomNavigationBarItem(icon: Icon(Icons.ac_unit), label: "ladno")
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: FutureBuilder<Position>(
              future: getLocation(),
              builder: (context, snapshot) {
                if (snapshot.data != null) {
                  return MapSample(snapshot.data!);
                } else {
                  return const Center(child: CircularProgressIndicator.adaptive());
                }
              }),
        ),
      ),
    );
  }
}

class MapSample extends StatefulWidget {
  final Position position;

  const MapSample(this.position, {super.key});

  @override
  State<MapSample> createState() => MapSampleState(position);
}

class MapSampleState extends State<MapSample> {
  final Position position;
  final Completer<GoogleMapController> _controller = Completer<GoogleMapController>();

  double size = 200;

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  static const CameraPosition _kLake = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(37.43296265331129, -122.08832357078792),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);

  MapSampleState(this.position);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: size,
        height: size,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onDoubleTap: () {
            setState(() {
              if (size - 200 <= 0) {
                size = 400;
              } else {
                size = 200;
              }
            });
          },
          child: GoogleMap(
            onTap: (argument) {},
            mapType: MapType.hybrid,
            initialCameraPosition:
                CameraPosition(target: LatLng(position.latitude, position.longitude), zoom: 19.151926040649414),
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _goToTheLake,
        label: const Text('To the lake!'),
        icon: const Icon(Icons.directions_boat),
      ),
    );
  }

  Future<void> _goToTheLake() async {
    final GoogleMapController controller = await _controller.future;
    await controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
  }
}

Future<Position> getLocation() async {
  await Geolocator.requestPermission().then((value) {}).onError((error, stackTrace) async {
    await Geolocator.requestPermission();
    print("ERROR" + error.toString());
  });
  return await Geolocator.getCurrentPosition();
}
