
import 'package:equatable/equatable.dart';

class LocationModel extends Equatable {
  final double lat;
  final double lng;

  const LocationModel({required this.lat, required this.lng});

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {'lat': lat, 'lng': lng};

  @override
  List<Object?> get props => [lat, lng];
}
