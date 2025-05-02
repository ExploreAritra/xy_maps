# xy_maps

**xy_maps** is a Flutter package that allows placing rich-commented markers on custom image backgrounds (e.g. floor plans). Users can zoom, pan, switch between edit/view mode, and export/import marker data using a GeoJSON-like format.

## ✨ Features

- 🗺️ Custom image as a map (e.g., floor plan, site layout)
- 🔍 Pinch to zoom and pan support via `InteractiveViewer`
- 🖱️ Tap to place markers in edit mode
- 📝 Add rich text comments (bold, italics, bullets, links) with `flutter_quill`
- 🧭 Edit/view mode toggle
- 🔄 Move existing markers
- 🗃️ GeoJSON-compatible import/export format
- ⚙️ State management with `provider`

## 📦 Installation

Add the package in your `pubspec.yaml`:

```yaml
dependencies:
  xy_maps: ^0.0.2
```

Then run:

```bash
flutter pub get
```

## 🚀 Getting Started

### 1. Wrap your widget tree in `ChangeNotifierProvider`

```dart
ChangeNotifierProvider(
  create: (_) => MarkerController(),
  child: MyApp(),
);
```

### 2. Add `XyMapView` to your widget tree

```dart
XyMapView(
  backgroundImage: AssetImage('assets/floorplan.png'),
  imageWidth: 1920,
  imageHeight: 1080,
  onMarkerAdded: (marker) {
    print('New marker: (${marker.x}, ${marker.y})');
  },
);
```

### 3. Switch between view and edit modes

```dart
final controller = context.read<MarkerController>();
controller.setMode(ViewMode.edit); // or ViewMode.view
```

## 📍 Marker Format

Marker data is represented in a GeoJSON-like format:

```json
{
  "type": "FeatureCollection",
  "features": [
    {
      "type": "Feature",
      "geometry": {
        "type": "Point",
        "coordinates": [0.5, 0.3]
      },
      "properties": {
        "comment": { "ops": [{ "insert": "Hello marker!\n" }] }
      }
    }
  ]
}
```

Use `GeoJsonMarker.toJson()` and `GeoJsonMarker.fromJson()` for conversion.

## 🧪 Example

To try it out quickly:

```bash
git clone https://github.com/ExploreAritra/xy_maps.git
cd xy_maps/example
flutter run
```

## 🖼️ Screenshots

![Drawing Usage](screenshots/usage.gif)

## 👨‍💻 Contributing

Pull requests are welcome! Please open issues for feature requests or bugs.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

Developed by [@ExploreAritra](https://github.com/ExploreAritra)