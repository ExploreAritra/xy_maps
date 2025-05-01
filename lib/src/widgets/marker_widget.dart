import 'dart:io';
import 'package:provider/provider.dart';
import 'package:vector_math/vector_math_64.dart' show Vector3, Matrix4;
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import '../models/geojson_marker.dart';
import '../controllers/marker_controller.dart';
import '../utils/mode_enum.dart';

class MarkerWidget extends StatelessWidget {
  final GeoJsonMarker marker;
  final double mapWidth;
  final double mapHeight;
  final TransformationController transformationController;  // Added

  const MarkerWidget({
    Key? key,
    required this.marker,
    required this.mapWidth,
    required this.mapHeight,
    required this.transformationController,  // Added
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = context.read<MarkerController>();
    final left = marker.x * mapWidth;
    final top = marker.y * mapHeight;

    return GestureDetector(
      onPanUpdate: controller.mode == ViewMode.edit
          ? (details) {
        // 1) Grab the map’s RenderBox (the InteractiveViewer child)
        final box = context.findAncestorRenderObjectOfType<RenderBox>()!;

        // 2) Convert the finger’s global position to the box’s local coords
        final local = box.globalToLocal(details.globalPosition);

        // 3) Apply the *inverse* of the current transform to undo scale/translate
        final inverseMatrix = Matrix4.inverted(transformationController.value);

        // 4) Now normalize into 0–1 based on the original image dimensions:
        final Vector3 untransformed = inverseMatrix.transform3(Vector3(local.dx, local.dy, 0));

        final newX = (untransformed.x / mapWidth).clamp(0.0, 1.0);
        final newY = (untransformed.y / mapHeight).clamp(0.0, 1.0);

        controller.updateMarkerPosition(marker.id, newX, newY);
      }
          : null,

      onTap: () => _showCommentDialog(context),
      child: Icon(
        Icons.location_on,
        size: 36,
        color: controller.mode == ViewMode.edit ? Colors.blue : Colors.red,
      ),
    );
  }

  void _showCommentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Marker Comment'),
        content: SizedBox(
          width: 300,
          height: 400,
          child: QuillEditor(
            controller: marker.commentController,
            scrollController: ScrollController(),
            focusNode: FocusNode(),
            config: QuillEditorConfig(
              checkBoxReadOnly: context.read<MarkerController>().mode == ViewMode.view,
              scrollable: true,
              autoFocus: false,
              padding: EdgeInsets.zero,
              expands: false,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
}
