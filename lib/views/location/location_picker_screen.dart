import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../controllers/location_controller.dart';
import '../../core/errors/app_error.dart';
import '../../core/errors/error_presenter.dart';
import '../../models/location_model.dart';

class LocationPickerScreen extends StatefulWidget {
  final NoteLocation? initialLocation;

  const LocationPickerScreen({super.key, this.initialLocation});

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  final LocationController _controller = LocationController.instance;
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();

  static const _defaultCenter = LatLng(48.8566, 2.3522); // Paris, par défaut

  LatLng? selectedPoint;
  String? placeName;
  String? address;
  bool isBusy = false;

  @override
  void initState() {
    super.initState();

    final initial = widget.initialLocation;
    if (initial != null) {
      selectedPoint = LatLng(initial.latitude, initial.longitude);
      placeName = initial.placeName;
      address = initial.address;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _useCurrentPosition() async {
    setState(() => isBusy = true);

    try {
      final location = await _controller.getCurrentLocation();
      final point = LatLng(location.latitude, location.longitude);

      setState(() {
        selectedPoint = point;
        address = location.address;
        placeName = null;
      });

      _mapController.move(point, 16);
    } catch (e) {
      if (!mounted) return;
      final message = e.toString().replaceFirst('Exception: ', '');
      ErrorPresenter.showError(context, AppError.validation(message));
    } finally {
      if (mounted) setState(() => isBusy = false);
    }
  }

  Future<void> _search() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() => isBusy = true);

    final results = await _controller.searchPlace(query);

    if (!mounted) return;
    setState(() => isBusy = false);

    if (results.isEmpty) {
      ErrorPresenter.showError(
        context,
        AppError.validation('Aucun lieu trouvé pour "$query".'),
      );
      return;
    }

    final result = results.first;
    final point = LatLng(result.latitude, result.longitude);

    setState(() {
      selectedPoint = point;
      address = result.address;
      placeName = query;
    });

    _mapController.move(point, 16);
  }

  Future<void> _onMapTap(TapPosition tapPosition, LatLng point) async {
    setState(() {
      selectedPoint = point;
      placeName = null;
      address = null;
    });

    final resolvedAddress = await _controller.addressFromCoordinates(
      point.latitude,
      point.longitude,
    );

    if (!mounted) return;
    setState(() => address = resolvedAddress);
  }

  void _confirm() {
    if (selectedPoint == null) return;

    Navigator.pop(
      context,
      NoteLocation(
        latitude: selectedPoint!.latitude,
        longitude: selectedPoint!.longitude,
        placeName: placeName,
        address: address,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Choisir un lieu"),
        actions: [
          TextButton(
            onPressed: selectedPoint == null ? null : _confirm,
            child: const Text("Valider"),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _search(),
                    decoration: InputDecoration(
                      hintText: "Rechercher un lieu...",
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: isBusy ? null : _useCurrentPosition,
                  icon: const Icon(Icons.my_location),
                  tooltip: "Utiliser ma position",
                ),
              ],
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: selectedPoint ?? _defaultCenter,
                    initialZoom: selectedPoint != null ? 16 : 5,
                    onTap: _onMapTap,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.bricebignan.noteflow',
                    ),
                    if (selectedPoint != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: selectedPoint!,
                            width: 40,
                            height: 40,
                            child: Icon(
                              Icons.location_pin,
                              color: theme.colorScheme.error,
                              size: 40,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                if (isBusy)
                  const Positioned(
                    top: 12,
                    right: 12,
                    child: CircularProgressIndicator(),
                  ),
              ],
            ),
          ),
          if (selectedPoint != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: theme.cardColor,
              child: Row(
                children: [
                  Icon(Icons.place, color: theme.colorScheme.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      placeName ??
                          address ??
                          '${selectedPoint!.latitude.toStringAsFixed(5)}, ${selectedPoint!.longitude.toStringAsFixed(5)}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
