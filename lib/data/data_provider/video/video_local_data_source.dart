import 'package:isar/isar.dart';

import '../../model/video/video.dart';

abstract class VideoLocalDataSource {
  Future<List<Video>> getAllVideos();
  Future<int> saveVideo(Video video);
  Future<bool> deleteVideoById(int id);
  Future<int> deleteVideos(List<int> ids);
  Stream<void> watchVideos();
  Stream<List<Video>> watchAllVideos();
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
  Future<int> saveVideo(Video video) async {
    return await _isar.writeTxn(() async {
      return await _isar.videos.put(video);
    });
  }

  @override
  Future<bool> deleteVideoById(int id) async {
    return await _isar.writeTxn(() async {
      return await _isar.videos.delete(id);
    });
  }

  @override
  Future<int> deleteVideos(List<int> ids) async {
    return await _isar.writeTxn(() async {
      return await _isar.videos.deleteAll(ids);
    });
  }

  @override
  Stream<void> watchVideos() {
    return _isar.videos.watchLazy();
  }
  
  @override
  Stream<List<Video>> watchAllVideos() {
    return _isar.videos.where().watch();
  }
}
