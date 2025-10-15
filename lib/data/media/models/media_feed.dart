import 'package:equatable/equatable.dart';

class MediaFeedModel extends Equatable {
  final String url;
  final String publicId;
  final String mediaType;
  final bool isFrontCamera;
  final String? location;
  final num? duration;
  final String? format;
  final int? width;
  final int? height;
  final int? fileSize;

  const MediaFeedModel({
    required this.url,
    required this.publicId,
    required this.mediaType,
    this.isFrontCamera = true,
    this.location,
    this.duration,
    this.format,
    this.width,
    this.height,
    this.fileSize,
  });

  @override
  List<Object?> get props => [
    url,
    publicId,
    mediaType,
    isFrontCamera,
    location,
    duration,
    format,
    width,
    height,
    fileSize,
  ];
}
