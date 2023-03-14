import '../../../utils/file_helper.dart';

import '../../data_provider/video/video_local_data_source.dart';
import '../../model/video/video.dart';

abstract class VideoRepository {
  Future<List<Video>> getAllVideos();
  Future<void> saveVideo(Video video);
  Future<void> deleteVideo(Video video);
  Future<void> deleteVideos(List<Video> videos);
}

class VideoRepositoryImpl implements VideoRepository {
  final VideoLocalDataSource _videoLocalDataSource;

  VideoRepositoryImpl({
    required VideoLocalDataSource videoLocalDataSource,
  }) : _videoLocalDataSource = videoLocalDataSource;

  @override
  Future<List<Video>> getAllVideos() async {
    return _videoLocalDataSource.getAllVideos();
  }

  @override
  Future<void> saveVideo(Video video) async {
    await _videoLocalDataSource.saveVideo(video);
  }

  @override
  Future<void> deleteVideo(Video video) async {
    await _videoLocalDataSource.deleteVideoById(video.id);
    await FileHelper.deleteFile(video.path);
    await FileHelper.deleteFile(video.thumbnailPath);
  }

  @override
  Future<void> deleteVideos(List<Video> videos) async {
    for (final video in videos) {
      await deleteVideo(video);
    }
  }
}
