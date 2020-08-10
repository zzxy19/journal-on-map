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

  static CameraPosition deduceCameraCenter(List<Location> coordinates) {
    return CameraPosition(
      target: LatLng(37.42796133580664, -122.085749655962),
      zoom: 14.4746,
    );
  }

  static Location locationResult2Location(LocationResult locationResult) {
    return Location(
        name: locationResult.address,
        coordinate: latlng2Coordinate(locationResult.latLng));
  }

  static Location position2Location(Position position, String name) {
    return Location(name: name, coordinate: position2Coordinate(position));
  }
}