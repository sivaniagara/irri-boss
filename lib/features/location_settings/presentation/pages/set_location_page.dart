import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/app_alerts.dart';
import '../cubit/location_cubit.dart';
import '../widgets/location_map_widget.dart';

class SetLocationPage extends StatefulWidget {
  final int userId;
  final int controllerId;
  final String? initialLatLong;

  const SetLocationPage({
    super.key,
    required this.userId,
    required this.controllerId,
    this.initialLatLong,
  });

  @override
  State<SetLocationPage> createState() => _SetLocationPageState();
}

class _SetLocationPageState extends State<SetLocationPage> {
  final TextEditingController _latController = TextEditingController();
  final TextEditingController _lngController = TextEditingController();
  GoogleMapController? _mapController;
  LatLng _currentPosition = const LatLng(10.7905, 78.7047); // Default position (Niagara)

  @override
  void initState() {
    super.initState();
    _initPosition();
  }

  void _initPosition() {
    if (widget.initialLatLong != null && widget.initialLatLong!.isNotEmpty) {
      try {
        final parts = widget.initialLatLong!.split(',');
        if (parts.length == 2) {
          final lat = double.tryParse(parts[0].trim());
          final lng = double.tryParse(parts[1].trim());
          if (lat != null && lng != null) {
            _currentPosition = LatLng(lat, lng);
          }
        }
      } catch (e) {
        // Fallback to default
      }
    }
    _latController.text = _currentPosition.latitude.toString();
    _lngController.text = _currentPosition.longitude.toString();
  }

  /// Updates the internal state, marker position and optionally the camera and text fields.
  void _updatePosition(LatLng position, {bool updateTextFields = true, bool moveCamera = false}) {
    // Validate bounds for Google Maps coordinates
    if (position.latitude < -90.0 || position.latitude > 90.0 || 
        position.longitude < -180.0 || position.longitude > 180.0) {
      return;
    }

    setState(() {
      _currentPosition = position;
      if (updateTextFields) {
        _latController.text = position.latitude.toString();
        _lngController.text = position.longitude.toString();
      }
    });

    if (moveCamera && _mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLng(position),
      );
    }
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) showErrorAlert(context: context, message: 'Location services are disabled.');
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) showErrorAlert(context: context, message: 'Location permissions are denied');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) showErrorAlert(context: context, message: 'Location permissions are permanently denied.');
      return;
    }

    final position = await Geolocator.getCurrentPosition();
    _updatePosition(LatLng(position.latitude, position.longitude), moveCamera: true);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LocationCubit, LocationState>(
      listener: (context, state) {
        if (state is LocationSuccess) {
          showSuccessAlert(context: context, message: "Location set successfully");
          context.pop(true);
        } else if (state is LocationError) {
          showErrorAlert(context: context, message: state.message);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Set Location"),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _latController,
                          decoration: const InputDecoration(
                            labelText: "Latitude",
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                          onChanged: (value) {
                            final lat = double.tryParse(value);
                            if (lat != null) {
                              _updatePosition(
                                LatLng(lat, _currentPosition.longitude), 
                                updateTextFields: false, 
                                moveCamera: true,
                              );
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: _lngController,
                          decoration: const InputDecoration(
                            labelText: "Longitude",
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                          onChanged: (value) {
                            final lng = double.tryParse(value);
                            if (lng != null) {
                              _updatePosition(
                                LatLng(_currentPosition.latitude, lng), 
                                updateTextFields: false, 
                                moveCamera: true,
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _getCurrentLocation,
                      icon: const Icon(Icons.my_location),
                      label: const Text("Use Current Location"),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: LocationMapWidget(
                initialPosition: _currentPosition,
                onMarkerDragEnd: (pos) => _updatePosition(pos, moveCamera: true),
                onTap: (pos) => _updatePosition(pos, moveCamera: true),
                onMapCreated: (ctrl) {
                  _mapController = ctrl;
                  _mapController!.animateCamera(CameraUpdate.newLatLng(_currentPosition));
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: BlocBuilder<LocationCubit, LocationState>(
                  builder: (context, state) {
                    return ElevatedButton(
                      onPressed: state is LocationLoading
                          ? null
                          : () {
                              context.read<LocationCubit>().setLocation(
                                    userId: widget.userId,
                                    controllerId: widget.controllerId,
                                    latLong: "${_currentPosition.latitude},${_currentPosition.longitude}",
                                  );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                      ),
                      child: state is LocationLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("Set Location", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }
}
