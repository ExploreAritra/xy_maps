// lib/widgets/xy_map_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../controllers/marker_controller.dart';
import '../models/geojson_marker.dart';
import '../utils/mode_enum.dart';
import 'marker_widget.dart';

class XyMapView extends StatefulWidget {
  final ImageProvider backgroundImage;
  final double imageWidth;
  final double imageHeight;
  final ValueChanged<GeoJsonMarker>? onMarkerAdded;

  const XyMapView({
    Key? key,
    required this.backgroundImage,
    required this.imageWidth,
    required this.imageHeight,
    this.onMarkerAdded,
  }) : super(key: key);

  @override
  State<XyMapView> createState() => _XyMapViewState();
}

class _XyMapViewState extends State<XyMapView> {
  final TransformationController _transformationCtrl = TransformationController();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final viewWidth = constraints.maxWidth;
        final viewHeight = constraints.maxHeight;

        final imageAspect = widget.imageWidth / widget.imageHeight;
        final viewAspect = viewWidth / viewHeight;

        double renderedWidth, renderedHeight;

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
                    final local = details.localPosition;
                    final x = (local.dx / renderedWidth).clamp(0.0, 1.0);
                    final y = (local.dy / renderedHeight).clamp(0.0, 1.0);

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
                        Image(
                          image: widget.backgroundImage,
                          width: renderedWidth,
                          height: renderedHeight,
                          fit: BoxFit.contain,
                        ),
                        ...controller.markers.map((marker) {
                          final left = marker.x * renderedWidth;
                          final top = marker.y * renderedHeight;
                          return Positioned(
                            left: left - 12,
                            top: top - 24,
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