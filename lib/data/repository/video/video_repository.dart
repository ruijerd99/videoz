import '../../../utils/file_helper.dart';

import '../../data_provider/video/video_local_data_source.dart';
import '../../model/video/video.dart';

abstract class VideoRepository {
  Future<List<Video>> getAllVideos();
  Future<int> saveVideo(Video video);
  Future<bool> deleteVideo(Video video);
  Future<int> deleteVideos(List<Video> videos);
  Stream<void> watchVideos();
}

class VideoRepositoryImpl implements VideoRepository {
  final VideoLocalDataSource _videoLocalDataSource;

  VideoRepositoryImpl({
    required VideoLocalDataSource videoLocalDataSource,
  }) : _videoLocalDataSource = videoLocalDataSource;

  @override
  Future<List<Video>> getAllVideos() async {
    return await _videoLocalDataSource.getAllVideos();
  }

  @override
  Future<int> saveVideo(Video video) async {
    return await _videoLocalDataSource.saveVideo(video);
  }

  @override
  Future<bool> deleteVideo(Video video) async {
    await FileHelper.deleteFile(video.getPath);
    await FileHelper.deleteFile(video.getThumbnailPath);

    return await _videoLocalDataSource.deleteVideoById(video.id);
  }

  @override
  Future<int> deleteVideos(List<Video> videos) async {
    for (final video in videos) {
      await FileHelper.deleteFile(video.getPath);
      await FileHelper.deleteFile(video.getThumbnailPath);
    }

    return await _videoLocalDataSource.deleteVideos(videos.map((e) => e.id).toList());
  }

  @override
  Stream<void> watchVideos() {
    return _videoLocalDataSource.watchVideos();
  }
}
