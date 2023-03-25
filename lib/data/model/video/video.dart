import 'package:isar/isar.dart';
import 'package:videoz/data/injector.dart';

part 'video.g.dart';

@collection
class Video {
  Id id;
  final String thumbnailPath;
  final String path;
  final int views;
  final double width;
  final double height;

  @ignore
  get getThumbnailPath => "$documentDir/$thumbnailPath";

  @ignore
  get getPath => "$documentDir/$path";


  Video({
    required this.path,
    required this.thumbnailPath,
    required this.width,
    required this.height,
    this.views = 0,
  }) : id = Isar.autoIncrement;
}
