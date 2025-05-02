import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:vector_math/vector_math_64.dart';

import '../controllers/marker_controller.dart';
import '../models/geojson_marker.dart';
import '../utils/mode_enum.dart';
import 'marker_widget.dart';

/// A widget that displays a zoomable and pannable image with interactive markers.
///
/// Markers can be added by tapping on the image when in [ViewMode.edit],
/// and each marker supports rich-text comments using [flutter_quill].
class XyMapView extends StatefulWidget {
  /// The background image (e.g., a floor plan or map).
  final ImageProvider backgroundImage;

  /// Logical width of the background image.
  final double imageWidth;

  /// Logical height of the background image.
  final double imageHeight;

  /// Optional callback invoked when a new marker is added.
  final ValueChanged<GeoJsonMarker>? onMarkerAdded;

  /// Creates an [XyMapView] widget.
  ///
  /// The [imageWidth] and [imageHeight] should match the original size of [backgroundImage].
  const XyMapView({
    super.key,
    required this.backgroundImage,
    required this.imageWidth,
    required this.imageHeight,
    this.onMarkerAdded,
  });

  @override
  State<XyMapView> createState() => _XyMapViewState();
}

class _XyMapViewState extends State<XyMapView> {
  /// Controller used for managing pan and zoom transformations.
  final TransformationController _transformationCtrl =
      TransformationController();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final viewWidth = constraints.maxWidth;
        final viewHeight = constraints.maxHeight;

        final imageAspect = widget.imageWidth / widget.imageHeight;
        final viewAspect = viewWidth / viewHeight;

        double renderedWidth, renderedHeight;

        // Adjust the image dimensions to fit inside the viewport while preserving aspect ratio
        if (imageAspect > viewAspect) {
          renderedWidth = viewWidth;
          renderedHeight = viewWidth / imageAspect;
        } else {
          renderedHeight = viewHeight;
          renderedWidth = viewHeight * imageAspect;
        }

        return Center(
          child: SizedBox(
            width: renderedWidth,
            height: renderedHeight,
            child: Consumer<MarkerController>(
              builder: (context, controller, _) {
                return GestureDetector(
                  onTapUp: controller.mode == ViewMode.edit
                      ? (details) {
                          // Convert tapped position to normalized coordinates
                          final inverseMatrix = Matrix4.inverted(
                            _transformationCtrl.value,
                          );
                          final local = details.localPosition;
                          final Vector3 untransformed = inverseMatrix
                              .transform3(Vector3(local.dx, local.dy, 0));

                          final x =
                              (untransformed.x / renderedWidth).clamp(0.0, 1.0);
                          final y = (untransformed.y / renderedHeight)
                              .clamp(0.0, 1.0);

                          // Create and add the marker
                          final id = const Uuid().v4();
                          final marker = GeoJsonMarker(
                            id: id,
                            x: x,
                            y: y,
                            commentController: QuillController.basic(),
                          );
                          controller.addMarker(marker);
                          widget.onMarkerAdded?.call(marker);
                        }
                      : null,
                  child: InteractiveViewer(
                    transformationController: _transformationCtrl,
                    clipBehavior: Clip.none,
                    panEnabled: true,
                    scaleEnabled: true,
                    child: Stack(
                      children: [
                        // Render background image
                        Image(
                          image: widget.backgroundImage,
                          width: renderedWidth,
                          height: renderedHeight,
                          fit: BoxFit.contain,
                        ),
                        // Render each marker in correct position
                        ...controller.markers.map((marker) {
                          final left = marker.x * renderedWidth;
                          final top = marker.y * renderedHeight;
                          return Positioned(
                            left: left - 12, // Centering adjustment
                            top: top - 24, // Centering adjustment
                            child: MarkerWidget(
                              marker: marker,
                              mapWidth: renderedWidth,
                              mapHeight: renderedHeight,
                              transformationController: _transformationCtrl,
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
