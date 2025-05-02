import 'dart:convert';
import '../models/geojson_marker.dart';

/// A service class for handling import and export of markers in GeoJSON format.
class GeoJsonService {
  /// Converts a list of [GeoJsonMarker] objects into a GeoJSON `FeatureCollection` string.
  ///
  /// This method serializes each marker into a GeoJSON feature and wraps them in a
  /// GeoJSON-compliant `FeatureCollection`.
  ///
  /// Returns a [String] containing the GeoJSON representation.
  static String exportGeoJson(List<GeoJsonMarker> markers) {
    final features = markers.map((m) => m.toGeoJsonFeature()).toList();
    final geoJson = {"type": "FeatureCollection", "features": features};
    return jsonEncode(geoJson);
  }

  /// Parses a GeoJSON `FeatureCollection` string and converts it to a list of [GeoJsonMarker] objects.
  ///
  /// Expects the input string to follow the standard GeoJSON format, particularly with
  /// `type: "FeatureCollection"` and a `features` array of GeoJSON features.
  ///
  /// Throws a [FormatException] if the JSON is invalid.
  ///
  /// Returns a [List] of [GeoJsonMarker] objects reconstructed from the features.
  static List<GeoJsonMarker> importGeoJson(String jsonString) {
    final Map<String, dynamic> data = jsonDecode(jsonString);
    final features = data['features'] as List;
    return features.map((f) => GeoJsonMarker.fromGeoJsonFeature(f)).toList();
  }
}
