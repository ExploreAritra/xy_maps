// lib/controllers/marker_controller.dart
import 'package:flutter/material.dart';
import '../models/geojson_marker.dart';
import '../utils/mode_enum.dart';

class MarkerController extends ChangeNotifier {
  final List<GeoJsonMarker> _markers = [];
  ViewMode _mode = ViewMode.view;

  List<GeoJsonMarker> get markers => List.unmodifiable(_markers);
  ViewMode get mode => _mode;

  void switchMode(ViewMode mode) {
    _mode = mode;
    notifyListeners();
  }

  void addMarker(GeoJsonMarker marker) {
    _markers.add(marker);
    notifyListeners();
  }

  void removeMarker(String id) {
    _markers.removeWhere((m) => m.id == id);
    notifyListeners();
  }

  void updateMarkerPosition(String id, double newX, double newY) {
    final marker = _markers.firstWhere((m) => m.id == id, orElse: () => throw Exception("Marker not found"));
    marker.x = newX;
    marker.y = newY;
    notifyListeners();
  }

  void clearMarkers() {
    _markers.clear();
    notifyListeners();
  }

  void importMarkers(List<GeoJsonMarker> imported) {
    _markers.clear();
    _markers.addAll(imported);
    notifyListeners();
  }
}
