// lib/models/geojson_marker.dart
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'dart:convert';

class GeoJsonMarker {
  final String id;
  double x;
  double y;
  QuillController commentController;

  GeoJsonMarker({
    required this.id,
    required this.x,
    required this.y,
    required this.commentController,
  });

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
