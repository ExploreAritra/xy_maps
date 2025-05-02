// lib/models/geojson_marker.dart
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'dart:convert';

/// GeoJsonMarker: Represents a marker placed on an XY coordinate system with an attached comment.
class GeoJsonMarker {
  /// The unique identifier for the marker.
  final String id;

  /// X-coordinate of the marker on the image.
  double x;

  /// Y-coordinate of the marker on the image.
  double y;

  /// Controller for the rich text comment associated with the marker.
  QuillController commentController;

  /// Creates a new GeoJsonMarker instance with given position and comment.
  GeoJsonMarker({
    required this.id,
    required this.x,
    required this.y,
    required this.commentController,
  });

  /// Converts this marker to a GeoJSON feature map.
  Map<String, dynamic> toGeoJsonFeature() => {
        "type": "Feature",
        "geometry": {
          "type": "Point",
          "coordinates": [x, y],
        },
        "properties": {
          "id": id,
          "comment": commentController.document.toDelta().toJson(),
        },
      };

  /// Constructs a GeoJsonMarker from a GeoJSON feature map.
  static GeoJsonMarker fromGeoJsonFeature(Map<String, dynamic> feature) {
    final coords = feature['geometry']['coordinates'];
    final props = feature['properties'];

    final commentRaw = props['comment'];

    final deltaJson = commentRaw is String
        ? jsonDecode(commentRaw)
        : commentRaw; // already a List

    return GeoJsonMarker(
      id: props['id'],
      x: coords[0],
      y: coords[1],
      commentController: QuillController(
        document: Document.fromJson(deltaJson),
        selection: const TextSelection.collapsed(offset: 0),
      ),
    );
  }
}
