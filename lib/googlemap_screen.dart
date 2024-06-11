import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';

class LocationPermissionScreen extends StatefulWidget {
  @override
  _LocationPermissionScreenState createState() =>
      _LocationPermissionScreenState();
}

class _LocationPermissionScreenState extends State<LocationPermissionScreen> {
  String _locationMessage = 'Requesting Location Permission...';
  late GoogleMapController mapController;
  LatLng _initialPosition = LatLng(12.9045, 80.1405);
  LatLng _destinationPosition = LatLng(0, 0);
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  Future<void> _checkLocationPermission() async {
    PermissionStatus status = await Permission.location.status;

    if (status.isDenied) {
      if (await Permission.location.request().isGranted) {
        // Permission granted
        _getLocation();
      } else {
        // Permission denied
        _showPermissionDeniedDialog();
      }
    } else if (status.isPermanentlyDenied) {
      // Permission permanently denied
      _showPermissionDeniedDialog();
    } else {
      // Permission already granted
      _getLocation();
    }
  }

  Future<void> _getLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _initialPosition =
            LatLng(position.latitude, position.longitude);
        _locationMessage =
        'Current location: Lat: ${position.latitude}, Lon: ${position.longitude}';
        _markers.clear();
        _markers.add(Marker(
          markerId: MarkerId("current_location"),
          position: _initialPosition,
          infoWindow: InfoWindow(title: "Your Location"),
        ));
      });
    } catch (e) {
      setState(() {
        _locationMessage = 'Failed to get location: $e';
      });
    }
  }

  void _updateMapLocation() {
    mapController.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        target: _initialPosition,
        zoom: 15.0,
      ),
    ));
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Permission Denied'),
        content: const Text(
            'Location permission is required to access this feature. Please enable it in settings.'),
        actions: [
          TextButton(
            child: Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _updateMapLocation();
  }

  void _calculateRoute(LatLng destination) async {
    // Clear previous markers
    _markers.clear();
    _markers.add(Marker(
      markerId: MarkerId("current_location"),
      position: _initialPosition,
      infoWindow: InfoWindow(title: "Your Location"),
    ));
    _markers.add(Marker(
      markerId: MarkerId("destination_location"),
      position: destination,
      infoWindow: InfoWindow(title: "Destination"),
    ));

    // Calculate route
    List<LatLng> points = await _getRouteCoordinates(destination);
    Set<Polyline> polylines = Set<Polyline>();
    polylines.add(Polyline(
      polylineId: PolylineId("route"),
      color: Colors.blue,
      points: points,
    ));

    setState(() {
      _markers.addAll(_markers);
      _markers.add(Marker(
        markerId: MarkerId("destination_location"),
        position: destination,
        infoWindow: InfoWindow(title: "Destination"),
      ));
    });
  }

  Future<List<LatLng>> _getRouteCoordinates(LatLng destination) async {
    // This function should fetch route coordinates from a routing service
    // For simplicity, let's just return a straight line between the two points
    return [_initialPosition, destination];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            GoogleMap(
              onMapCreated: _onMapCreated,
              onTap: (position) {
                setState(() {
                  _destinationPosition = position;
                  _calculateRoute(position);
                });
              },
              initialCameraPosition: CameraPosition(
                target: _initialPosition,
                zoom: 15.0,
              ),
              markers: _markers,
            ),
            Positioned(
              top: 10.0,
              right: 15.0,
              left: 15.0,
              child: Container(
                padding:
                EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.0),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10.0,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  _locationMessage,
                  style: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
