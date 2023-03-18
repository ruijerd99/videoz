import 'package:isar/isar.dart';
import 'package:videoz/data/injector.dart';

part 'video.g.dart';

@collection
class Video {
  Id id;
  final String thumbnailPath;
  final String path;
  final int views;

  @ignore
  get getThumbnailPath => "$documentDir/$thumbnailPath";

  @ignore
  get getPath => "$documentDir/$path";


  Video({
    required this.path,
    required this.thumbnailPath,
    this.views = 0,
  }) : id = Isar.autoIncrement;

  Video copyWith({
    String? thumbnailPath,
    String? path,
    int? views,
  }) {
    return Video(
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      path: path ?? this.path,
      views: views ?? this.views,
    )..id = id;
  }
}
