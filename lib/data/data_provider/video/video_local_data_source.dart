import 'package:isar/isar.dart';

import '../../model/video/video.dart';

abstract class VideoLocalDataSource {
  Future<List<Video>> getAllVideos();
  Future<void> saveVideo(Video video);
  Future<void> deleteVideoById(int id);
  Future<void> deleteVideos(List<int> ids);
}

class VideoLocalDataSourceImpl implements VideoLocalDataSource {
  final Isar _isar;

  VideoLocalDataSourceImpl(this._isar);

  @override
  Future<List<Video>> getAllVideos() async {
    final videos = await _isar.videos.where().findAll();
    return videos;
  }

  @override
  Future<void> saveVideo(Video video) async {
    await _isar.writeTxn(() async {
      await _isar.videos.put(video);
    });
  }

  @override
  Future<void> deleteVideoById(int id) async {
    await _isar.writeTxn(() async {
      await _isar.videos.delete(id);
    });
  }

  @override
  Future<void> deleteVideos(List<int> ids) async {
    await _isar.writeTxn(() async {
      await _isar.videos.deleteAll(ids);
    });
  }
}
