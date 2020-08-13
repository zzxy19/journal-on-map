import 'dart:math';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_map_location_picker/google_map_location_picker.dart';
import 'proto.dart';
import 'package:geolocator/geolocator.dart';

class GoogleMapLocationUtil {
  // Private constructor to prevent instantiation.
  GoogleMapLocationUtil._();

  static LatLng coordinate2Latlng(Coordinate coordinate) {
    return LatLng(coordinate.latitude, coordinate.longitude);
  }

  static Coordinate latlng2Coordinate(LatLng latLng) {
    return Coordinate(latitude: latLng.latitude, longitude: latLng.longitude);
  }

  static Coordinate position2Coordinate(Position position) {
    return Coordinate(latitude: position.latitude, longitude: position.longitude);
  }

  static CameraPosition fromCoordinateAndZoom(Coordinate coordinate, double zoomLevel) {
    return CameraPosition(
      target: coordinate2Latlng(coordinate),
      zoom: zoomLevel,
    );
  }

  static CameraPosition initialCameraPosition() {
    return CameraPosition(
      target: LatLng(0, -100),
      zoom: 1.0,
    );
  }

  static CameraUpdate deduceCameraCenter(List<Location> coordinates) {
    if (coordinates.isEmpty) {
      return null;
    }
    if (coordinates.length == 1) {
      return _focusOnMostRecent(coordinates);
    }
    List<Location> mostRecentFive = coordinates.sublist(0, min(5, coordinates.length));
    LatLngBounds latLngBoundsForMostRecentFive = _computeLatLngBounds(mostRecentFive);
    if (_getMaxStretch(latLngBoundsForMostRecentFive) < 30) {
      return _includeAll(latLngBoundsForMostRecentFive);
    }
    return _focusOnMostRecent(mostRecentFive);
  }

  /// Works well when all points fit in one screen
  static CameraUpdate _includeAll(LatLngBounds latLngBounds) {
    return CameraUpdate.newLatLngBounds(latLngBounds, 50);
  }

  /// Works well when points are far away
  static CameraUpdate _focusOnMostRecent(List<Location> coordinates) {
    return CameraUpdate.newLatLngZoom(
        coordinate2Latlng(coordinates.elementAt(0).coordinate), _adaptiveZoom(coordinates));
  }

  static double _adaptiveZoom(List<Location> coordinates) {
    if (coordinates.length == 1) {
      return 6.0;
    }
    LatLngBounds latLngBounds = _computeLatLngBounds(coordinates);
    double maxStretch = _getMaxStretch(latLngBounds);
    double maybeZoom = 50.0 / maxStretch;
    if (maybeZoom < 0.5) {
      return 0.5;
    }
    if (maybeZoom > 16) {
      return 16;
    }
    return maybeZoom;
  }

  static double _getMaxStretch(LatLngBounds latLngBounds) {
    return max(
        latLngBounds.northeast.latitude - latLngBounds.southwest.latitude,
        latLngBounds.northeast.longitude - latLngBounds.southwest.longitude);
  }

  static LatLngBounds _computeLatLngBounds(List<Location> coordinates) {
    Location firstLocation = coordinates.elementAt(0);
    double maxLat = firstLocation.coordinate.latitude;
    double minLat = maxLat;
    double maxLng = firstLocation.coordinate.longitude;
    double minLng = maxLng;
    for (Location location in coordinates.sublist(1)) {
      maxLat = max(maxLat, location.coordinate.latitude);
      minLat = min(minLat, location.coordinate.latitude);
      maxLng = max(maxLng, location.coordinate.longitude);
      minLng = min(minLng, location.coordinate.longitude);
    }
    return LatLngBounds(
        southwest: LatLng(minLat, minLng),
        northeast: LatLng(maxLat, maxLng));
  }


  static Location locationResult2Location(LocationResult locationResult) {
    return Location(
        name: locationResult.address,
        coordinate: latlng2Coordinate(locationResult.latLng));
  }
}