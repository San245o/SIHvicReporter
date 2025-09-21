import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/map_provider.dart';
import '../widgets/map_marker_sheet.dart';
import '../widgets/leaflet_map.dart';
import 'package:latlong2/latlong.dart';
import '../widgets/animated_bottom_nav.dart';
import '../core/theme.dart';
import '../core/constants.dart';
import '../core/env.dart';

class MapsPage extends ConsumerStatefulWidget {
  const MapsPage({super.key});
  
  @override
  ConsumerState<MapsPage> createState() => _MapsPageState();
}

class _MapsPageState extends ConsumerState<MapsPage> {
  @override
  void initState() {
    super.initState();
    // Load map markers
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(mapProvider.notifier).fetchMarkers();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final mapState = ref.watch(mapProvider);
    final mapNotifier = ref.read(mapProvider.notifier);
    
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
          tooltip: 'Back to Home',
        ),
        title: const Text('Maps'),
        actions: [
          IconButton(
            icon: Icon(mapState.showClusters ? Icons.layers : Icons.layers_outlined),
            onPressed: () => mapNotifier.toggleClusters(),
            tooltip: 'Toggle Clusters',
          ),
          IconButton(
            icon: Icon(mapState.showHeatmap ? Icons.whatshot : Icons.whatshot_outlined),
            onPressed: () => mapNotifier.toggleHeatmap(),
            tooltip: 'Toggle Heatmap',
          ),
          PopupMenuButton<String>(
            onSelected: (value) => _handleFilterAction(value),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'area',
                child: Text('Filter by Area'),
              ),
              const PopupMenuItem(
                value: 'category',
                child: Text('Filter by Category'),
              ),
              const PopupMenuItem(
                value: 'severity',
                child: Text('Filter by Severity'),
              ),
              const PopupMenuItem(
                value: 'clear',
                child: Text('Clear Filters'),
              ),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          // Map View
          _buildMapView(mapState),
          
          // Loading Overlay
          if (mapState.isLoading)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          
          // Error Overlay
          if (mapState.error != null)
            Container(
              color: Colors.black26,
              child: Center(
                child: Container(
                  margin: const EdgeInsets.all(32),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 48,
                        color: AppTheme.errorColor,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Failed to load map',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        mapState.error!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => ref.read(mapProvider.notifier).refreshMarkers(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          
          // Map Controls
          _buildMapControls(mapState),
          
          // Statistics Panel
          _buildStatisticsPanel(mapState),
        ],
      ),
      bottomNavigationBar: const CivicBottomNavBar(currentIndex: 1),
    );
  }
  
  Widget _buildMapView(MapState mapState) {
    // Leaflet map implementation (no API key needed)
    final center = LatLng(Env.defaultLatitude, Env.defaultLongitude);
    return LeafletMapWidget(
      center: center,
      zoom: Env.defaultZoom,
      markers: mapState.markers,
      onMarkerTap: (marker) => _showMarkerDetails(marker),
    );
  }
  
  
  Widget _buildMapControls(MapState mapState) {
    return Positioned(
      top: 16,
      right: 16,
      child: Column(
        children: [
          // My Location Button
          FloatingActionButton.small(
            onPressed: _getCurrentLocation,
            backgroundColor: Theme.of(context).cardColor,
            child: const Icon(Icons.my_location, color: AppTheme.primaryColor),
          ),
          const SizedBox(height: 8),
          
          // Refresh Button
          FloatingActionButton.small(
            onPressed: () => ref.read(mapProvider.notifier).refreshMarkers(),
            backgroundColor: Theme.of(context).cardColor,
            child: const Icon(Icons.refresh, color: AppTheme.primaryColor),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatisticsPanel(MapState mapState) {
    return Positioned(
      bottom: 16,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Statistics',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Total',
                    mapState.markers.length.toString(),
                    AppTheme.primaryColor,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'High',
                    mapState.markers.where((m) => m.severity == 'High').length.toString(),
                    AppTheme.highSeverityColor,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Medium',
                    mapState.markers.where((m) => m.severity == 'Medium').length.toString(),
                    AppTheme.mediumSeverityColor,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Low',
                    mapState.markers.where((m) => m.severity == 'Low').length.toString(),
                    AppTheme.lowSeverityColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
        ),
      ],
    );
  }
  
  void _handleFilterAction(String action) {
    switch (action) {
      case 'area':
        _showAreaFilter();
        break;
      case 'category':
        _showCategoryFilter();
        break;
      case 'severity':
        _showSeverityFilter();
        break;
      case 'clear':
        ref.read(mapProvider.notifier).clearFilters();
        break;
    }
  }
  
  void _showAreaFilter() {
    showModalBottomSheet(
      context: context,
      builder: (context) => _buildFilterBottomSheet(
        'Filter by Area',
        AppConstants.areas,
        (area) => ref.read(mapProvider.notifier).filterByArea(area),
      ),
    );
  }
  
  void _showCategoryFilter() {
    showModalBottomSheet(
      context: context,
      builder: (context) => _buildFilterBottomSheet(
        'Filter by Category',
        AppConstants.categories,
        (category) => ref.read(mapProvider.notifier).filterByCategory(category),
      ),
    );
  }
  
  void _showSeverityFilter() {
    showModalBottomSheet(
      context: context,
      builder: (context) => _buildFilterBottomSheet(
        'Filter by Severity',
        AppConstants.severityLevels,
        (severity) {
          // TODO: Implement severity filtering
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Filtering by $severity')),
          );
        },
      ),
    );
  }
  
  Widget _buildFilterBottomSheet(String title, List<String> items, Function(String) onSelected) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ...items.map((item) => ListTile(
            title: Text(item),
            onTap: () {
              Navigator.pop(context);
              onSelected(item);
            },
          )),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(mapProvider.notifier).clearFilters();
            },
            child: const Text('Clear Filters'),
          ),
        ],
      ),
    );
  }
  
  void _showMarkerDetails(marker) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => MapMarkerSheet(
        marker: marker,
        onOpenPost: () {
          Navigator.pop(context);
          context.push('/post/${marker.postId}');
        },
      ),
    );
  }
  
  void _getCurrentLocation() {
    // TODO: Implement real location service
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Getting current location...')),
    );
  }
}
