import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationMapWidget extends StatelessWidget {
  final LatLng initialPosition;
  final Function(LatLng) onMarkerDragEnd;
  final Function(GoogleMapController) onMapCreated;

  const LocationMapWidget({
    super.key,
    required this.initialPosition,
    required this.onMarkerDragEnd,
    required this.onMapCreated,
  });

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      onMapCreated: onMapCreated,
      initialCameraPosition: CameraPosition(
        target: initialPosition,
        zoom: 15,
      ),
      markers: {
        Marker(
          markerId: const MarkerId("selected_location"),
          position: initialPosition,
          draggable: true,
          onDragEnd: onMarkerDragEnd,
        ),
      },
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
    );
  }
}
