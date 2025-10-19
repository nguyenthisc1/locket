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

  factory MediaFeedModel.fromJson(Map<String, dynamic> json) {
    return MediaFeedModel(
      url: json['url'] as String,
      publicId: json['publicId'] as String,
      mediaType: json['mediaType'] as String,
      isFrontCamera: json['isFrontCamera'] is bool
          ? json['isFrontCamera'] as bool
          : true, // Default to true if not present or not a bool
      location: json['location'] as String?,
      duration: json['duration'] as num?,
      format: json['format'] as String?,
      width: json['width'] as int?,
      height: json['height'] as int?,
      fileSize: json['fileSize'] as int?,
    );
  }

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
