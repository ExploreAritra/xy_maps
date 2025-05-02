import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:xy_maps/xy_maps.dart';

class ExampleApp extends StatefulWidget {
  const ExampleApp({super.key});

  @override
  State<ExampleApp> createState() => _ExampleAppState();
}

class _ExampleAppState extends State<ExampleApp> {
  late MarkerController _controller;
  final List<String> _importedIds = [];
  Uint8List? _imageBytes;
  double? _imageWidth;
  double? _imageHeight;

  @override
  void initState() {
    super.initState();
    _controller = MarkerController();
  }

  int get _newCount =>
      _controller.markers.where((m) => !_importedIds.contains(m.id)).length;

  void _handleImport() async {
    _controller.clearMarkers();
    String json = await _pickGeoJson();
    final imported = GeoJsonService.importGeoJson(json);
    _controller.importMarkers(imported);
    setState(() {
      _importedIds.clear();
      _importedIds.addAll(imported.map((m) => m.id));
    });
  }

  Future<String> _pickGeoJson() async {
    return Future.value(
      r'''{"type":"FeatureCollection","features":[{"type":"Feature","geometry":{"type":"Point","coordinates":[0.2979556857260093,0.30483959851115683]},"properties":{"id":"829c803a-adcb-4abb-9c5a-afaa8cfa6cf9","comment":[{"insert":"Dinner table \n"}]}},{"type":"Feature","geometry":{"type":"Point","coordinates":[0.4361733462607401,0.8318865239851486]},"properties":{"id":"4d34a4e5-811f-475f-b62d-3461d6b43de9","comment":[{"insert":"Couch\n"}]}},{"type":"Feature","geometry":{"type":"Point","coordinates":[0.8763572983276048,0.7309377465030732]},"properties":{"id":"7623f1b9-cfe2-419f-8cf7-79287786ce3d","comment":[{"insert":"Bed room\n"}]}}]}''',
    );
  }

  void _exportAll() {
    final json = GeoJsonService.exportGeoJson(_controller.markers);
    _showJsonDialog(json);
  }

  void _syncNew() {
    final newMarkers =
        _controller.markers.where((m) => !_importedIds.contains(m.id)).toList();
    final json = GeoJsonService.exportGeoJson(newMarkers);
    _showJsonDialog(json);
    setState(() {
      _importedIds.addAll(newMarkers.map((m) => m.id));
    });
  }

  void _showJsonDialog(String json) {
    debugPrint(json);
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text('Exported GeoJSON'),
            content: SingleChildScrollView(child: Text(json)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Close'),
              ),
            ],
          ),
    );
  }

  void _onMarkerAdded(GeoJsonMarker marker) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text('Add Comment'),
            content: SingleChildScrollView(
              child: SizedBox(
                width: 300,
                height: 400,
                child: QuillEditor(
                  controller: marker.commentController,
                  config: QuillEditorConfig(
                    checkBoxReadOnly: false,
                    scrollable: true,
                    autoFocus: true,
                    padding: EdgeInsets.zero,
                    expands: false,
                  ),
                  scrollController: ScrollController(),
                  focusNode: FocusNode(),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Done'),
              ),
            ],
          ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      final decoded = await decodeImageFromList(bytes);
      setState(() {
        _controller.clearMarkers();
        _imageBytes = bytes;
        _imageWidth = decoded.width.toDouble();
        _imageHeight = decoded.height.toDouble();
      });
    }
  }

  Future<ui.Image> getImageDimensions(AssetImage assetImage) async {
    final completer = Completer<ui.Image>();
    final stream = assetImage.resolve(ImageConfiguration());
    final listener = ImageStreamListener((ImageInfo info, bool _) {
      completer.complete(info.image);
    });

    stream.addListener(listener);
    final image = await completer.future;
    stream.removeListener(listener);
    return image; // You can access image.width and image.height
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<MarkerController>.value(
      value: _controller,
      child: MaterialApp(
        home: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            title: Text('XY Maps Example'),
            actions: [
              IconButton(
                icon: Icon(Icons.file_upload),
                onPressed: _handleImport,
              ),
              IconButton(
                icon: Icon(Icons.file_download),
                onPressed: _exportAll,
              ),
              PopupMenuButton<ImageSource>(
                onSelected: _pickImage,
                itemBuilder:
                    (context) => [
                      PopupMenuItem(
                        value: ImageSource.gallery,
                        child: Text('Pick from Gallery'),
                      ),
                      PopupMenuItem(
                        value: ImageSource.camera,
                        child: Text('Capture with Camera'),
                      ),
                    ],
              ),
            ],
          ),
          body:
              _imageBytes != null && _imageWidth != null && _imageHeight != null
                  ? XyMapView(
                    backgroundImage: MemoryImage(_imageBytes!),
                    imageWidth: _imageWidth!,
                    imageHeight: _imageHeight!,
                    onMarkerAdded: _onMarkerAdded,
                  )
                  : FutureBuilder(
                    future: getImageDimensions(
                      AssetImage("assets/floorplan.jpg"),
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.data == null) {
                        return Center(child: CircularProgressIndicator());
                      }
                      return XyMapView(
                        backgroundImage: AssetImage("assets/floorplan.jpg"),
                        imageWidth: snapshot.data!.width.toDouble(),
                        imageHeight: snapshot.data!.height.toDouble(),
                        onMarkerAdded: _onMarkerAdded,
                      );
                    },
                  ),
          // : Center(child: Text('Select an image to begin.')),
          floatingActionButton: Consumer<MarkerController>(
            builder: (context, controller, _) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  FloatingActionButton(
                    heroTag: 'mode',
                    child: Icon(
                      _controller.mode == ViewMode.view
                          ? Icons.edit
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      _controller.switchMode(
                        _controller.mode == ViewMode.view
                            ? ViewMode.edit
                            : ViewMode.view,
                      );
                    },
                  ),
                  SizedBox(height: 20),
                  if (_newCount > 0)
                    FloatingActionButton.extended(
                      heroTag: 'sync',
                      label: Text('Sync ($_newCount)'),
                      icon: Icon(Icons.sync),
                      onPressed: _syncNew,
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
