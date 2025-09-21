import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../core/env.dart';
import '../core/theme.dart';
import '../providers/map_provider.dart' show MapMarker;

class LeafletMapWidget extends StatefulWidget {
  final LatLng center;
  final double zoom;
  final List<MapMarker> markers;
  final Function(LatLng)? onTap;
  final Function(MapMarker)? onMarkerTap;

  const LeafletMapWidget({
    super.key,
    required this.center,
    this.zoom = 13.0,
    this.markers = const [],
    this.onTap,
    this.onMarkerTap,
  });

  @override
  State<LeafletMapWidget> createState() => _LeafletMapWidgetState();
}

class _LeafletMapWidgetState extends State<LeafletMapWidget> {
  late MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  @override
  Widget build(BuildContext context) {
    // Always use the default light map tiles regardless of app theme
    final tiles = Env.mapTileUrl;

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: widget.center,
        initialZoom: widget.zoom,
        onTap: (tapPosition, point) => widget.onTap?.call(point),
        minZoom: 5.0,
        maxZoom: 18.0,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: tiles,
          userAgentPackageName: 'com.civicreporter.app',
          maxZoom: 18,
          subdomains: const ['a', 'b', 'c'],
          // You can add attributionBuilder if you want a visible attribution widget
        ),
        MarkerLayer(
          markers: widget.markers.map((mapMarker) => _buildMarker(mapMarker)).toList(),
        ),
      ],
    );
  }

  Marker _buildMarker(MapMarker mapMarker) {
    final severityColor = AppTheme.getSeverityColor(mapMarker.severity);
    final statusColor = AppTheme.getStatusColor(mapMarker.status);
    
    return Marker(
      point: LatLng(mapMarker.latitude, mapMarker.longitude),
      width: 40.0,
      height: 40.0,
      child: GestureDetector(
        onTap: () => widget.onMarkerTap?.call(mapMarker),
        child: Stack(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: severityColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(
                _getIconForCategory(mapMarker.category),
                color: Colors.white,
                size: 20,
              ),
            ),
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'potholes':
        return Icons.warning;
      case 'streetlights':
        return Icons.lightbulb;
      case 'garbage':
        return Icons.delete;
      case 'water supply':
        return Icons.water_drop;
      case 'traffic':
        return Icons.traffic;
      case 'construction':
        return Icons.construction;
      case 'safety':
        return Icons.security;
      case 'parks':
        return Icons.park;
      default:
        return Icons.location_on;
    }
  }

  void zoomToLocation(LatLng location, {double zoom = 15.0}) {
    _mapController.move(location, zoom);
  }

  void fitBounds(List<LatLng> points) {
    if (points.isEmpty) return;
    final bounds = LatLngBounds.fromPoints(points);
    _mapController.fitCamera(CameraFit.bounds(
      bounds: bounds,
      padding: const EdgeInsets.all(50),
    ));
  }
}
