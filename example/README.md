# XY Maps Example App

This is an example Flutter application demonstrating the use of the [`xy_maps`](https://github.com/ExploreAritra/xy_maps) package to place, annotate, and manage markers on custom floorplan images.

## Features

- Load image from asset, gallery, or camera
- Tap to add rich text comments as markers
- Edit/view modes for marker interaction
- Import/export marker data in GeoJSON format
- Sync new markers to external systems

## Getting Started

### Run the App

Clone the repository and navigate to the `example/` folder:

```bash
git clone https://github.com/ExploreAritra/xy_maps.git
cd xy_maps/example
flutter pub get
flutter run
```

### Permissions

Ensure your app requests the appropriate permissions for camera and gallery access in `AndroidManifest.xml` and `Info.plist`.

## Screenshots

| Floorplan View | Marker Comment | Export JSON |
|----------------|----------------|-------------|
| ![floor](https://via.placeholder.com/150) | ![comment](https://via.placeholder.com/150) | ![export](https://via.placeholder.com/150) |

## How It Works

- Users can tap the map in "Edit" mode to place a marker.
- A rich text editor (using `flutter_quill`) lets them enter a formatted comment.
- All markers can be exported as GeoJSON.
- GeoJSON can be imported to pre-populate the map.

## GeoJSON Format

Markers are stored using a valid [GeoJSON](https://geojson.org/) format:

```json
{
  "type": "FeatureCollection",
  "features": [
    {
      "type": "Feature",
      "geometry": {
        "type": "Point",
        "coordinates": [0.4, 0.6]
      },
      "properties": {
        "id": "marker-id",
        "comment": [{ "insert": "This is a room\n" }]
      }
    }
  ]
}
```

## License

MIT © [ExploreAritra](https://github.com/ExploreAritra)
