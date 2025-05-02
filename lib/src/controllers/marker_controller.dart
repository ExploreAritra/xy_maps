// lib/controllers/marker_controller.dart
import 'package:flutter/material.dart';
import '../models/geojson_marker.dart';
import '../utils/mode_enum.dart';

/// MarkerController: Manages the collection of markers and handles edit/view modes.
class MarkerController extends ChangeNotifier {
  /// The list of markers currently present on the image.
  final List<GeoJsonMarker> _markers = [];

  /// Current view mode (edit or view).
  ViewMode _mode = ViewMode.view;

  List<GeoJsonMarker> get markers => List.unmodifiable(_markers);
  ViewMode get mode => _mode;

  /// Switches the view/edit mode.
  void switchMode(ViewMode mode) {
    _mode = mode;
    notifyListeners();
  }

  /// Adds a new marker to the list.
  void addMarker(GeoJsonMarker marker) {
    _markers.add(marker);
    notifyListeners();
  }

  /// Removes a marker by its ID.
  void removeMarker(String id) {
    _markers.removeWhere((m) => m.id == id);
    notifyListeners();
  }

  /// Updates marker position on pan update
  void updateMarkerPosition(String id, double newX, double newY) {
    final marker = _markers.firstWhere(
      (m) => m.id == id,
      orElse: () => throw Exception("Marker not found"),
    );
    marker.x = newX;
    marker.y = newY;
    notifyListeners();
  }

  /// Clears all markers.
  void clearMarkers() {
    _markers.clear();
    notifyListeners();
  }

  /// Replaces current markers with a new imported list.
  void importMarkers(List<GeoJsonMarker> imported) {
    _markers.clear();
    _markers.addAll(imported);
    notifyListeners();
  }
}
