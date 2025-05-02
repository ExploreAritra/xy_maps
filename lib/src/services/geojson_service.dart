// lib/services/geojson_service.dart
import 'dart:convert';
import '../models/geojson_marker.dart';

class GeoJsonService {
  static String exportGeoJson(List<GeoJsonMarker> markers) {
    final features = markers.map((m) => m.toGeoJsonFeature()).toList();
    final geoJson = {
      "type": "FeatureCollection",
      "features": features,
    };
    return jsonEncode(geoJson);
  }

  static List<GeoJsonMarker> importGeoJson(String jsonString) {
    final Map<String, dynamic> data = jsonDecode(jsonString);
    final features = data['features'] as List;
    return features.map((f) => GeoJsonMarker.fromGeoJsonFeature(f)).toList();
  }
}
