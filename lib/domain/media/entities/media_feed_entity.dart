import 'package:equatable/equatable.dart';

class MediaFeedEntity extends Equatable {
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

  const MediaFeedEntity({
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

  MediaFeedEntity copyWith({
    String? url,
    String? publicId,
    String? mediaType,
    bool? isFrontCamera,
    String? location,
    num? duration,
    String? format,
    int? width,
    int? height,
    int? fileSize,
  }) {
    return MediaFeedEntity(
      url: url ?? this.url,
      publicId: publicId ?? this.publicId,
      mediaType: mediaType ?? this.mediaType,
      isFrontCamera: isFrontCamera ?? this.isFrontCamera,
      location: location ?? this.location,
      duration: duration ?? this.duration,
      format: format ?? this.format,
      width: width ?? this.width,
      height: height ?? this.height,
      fileSize: fileSize ?? this.fileSize,
    );
  }
}
