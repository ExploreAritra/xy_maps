/// Enum representing the interaction mode of the map view.
///
/// - [view]: The map is in read-only mode. Markers cannot be moved or added.
/// - [edit]: The map allows marker placement and movement.
enum ViewMode {
  /// Read-only mode: users can view but not modify markers.
  view,

  /// Edit mode: users can add or move markers.
  edit,
}
