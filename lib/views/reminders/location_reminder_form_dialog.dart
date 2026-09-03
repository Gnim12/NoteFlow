import 'package:flutter/material.dart';

import '../../models/location_model.dart';
import '../location/location_picker_screen.dart';

typedef LocationReminderDraft = ({
  double latitude,
  double longitude,
  double radiusMeters,
  String? placeName,
});

/// Enchaîne le sélecteur de lieu (réutilisé de la phase 7) puis un réglage
/// du rayon de déclenchement, pour créer un rappel géolocalisé.
Future<LocationReminderDraft?> showLocationReminderFormDialog(
  BuildContext context,
) async {
  final location = await Navigator.push<NoteLocation>(
    context,
    MaterialPageRoute(builder: (_) => const LocationPickerScreen()),
  );

  if (location == null || !context.mounted) return null;

  final radius = await showDialog<double>(
    context: context,
    builder: (_) => _RadiusDialog(location: location),
  );

  if (radius == null) return null;

  return (
    latitude: location.latitude,
    longitude: location.longitude,
    radiusMeters: radius,
    placeName: location.placeName ?? location.address,
  );
}

class _RadiusDialog extends StatefulWidget {
  final NoteLocation location;

  const _RadiusDialog({required this.location});

  @override
  State<_RadiusDialog> createState() => _RadiusDialogState();
}

class _RadiusDialogState extends State<_RadiusDialog> {
  double radius = 200;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Rayon de déclenchement"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.location.displayLabel,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          Text("${radius.round()} m autour du lieu"),
          Slider(
            value: radius,
            min: 50,
            max: 2000,
            divisions: 39,
            label: "${radius.round()} m",
            onChanged: (value) => setState(() => radius = value),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Annuler"),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, radius),
          child: const Text("Créer le rappel"),
        ),
      ],
    );
  }
}
