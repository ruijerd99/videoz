import 'dart:developer';
import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:videoz/data/injector.dart';
import 'package:videoz/utils/common_func.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

import '../../../data/model/video/video.dart';
import '../../../data/repository/video/video_repository.dart';
import '../../../utils/file_helper.dart';

part 'video_import_state.dart';

class VideoImportCubit extends Cubit<VideoImportState> {
  VideoImportCubit() : super(VideoImportInitial());

  Future<void> addVideosButtonPressed(BuildContext context) async {
    final assets = await AssetPicker.pickAssets(
      context,
      pickerConfig: const AssetPickerConfig(
        requestType: RequestType.video,
        maxAssets: 30,
      ),
    );

    if (assets == null || assets.isEmpty) {
      return;
    }

    showLoading();

    final dir = await getApplicationDocumentsDirectory();

    BotToast.showText(text: 'Importing ${assets.length} videos...');

    final processingResults = await Future.wait(assets.map((asset) async {
      final videoFile = await asset.file;
      if (videoFile == null) {
        return _VideoProcessingResult(
          success: false,
          errorMessage: 'Failed to get video file from asset: $asset',
        );
      }

      final fileExtension = FileHelper.getFileExtension(videoFile);
      final fileName =
          FileHelper.getFileName(file: videoFile, fileExtension: fileExtension);
      final newPath = '${dir.path}/$fileName.$fileExtension';

      final file = File(newPath);
      if (await file.exists()) {
        return _VideoProcessingResult(
          success: false,
          errorMessage: 'File already exists: $newPath',
        );
      }

      try {
        final newVideoFile = await videoFile.copy(newPath);

        final thumbnailData = await VideoThumbnail.thumbnailData(
          video: newPath,
          imageFormat: ImageFormat.PNG,
          quality: 100,
        );

        if (thumbnailData == null) {
          return _VideoProcessingResult(
            success: false,
            errorMessage: 'Failed to generate thumbnail for video: $newPath',
          );
        }

        final thumbnail = await File('${dir.path}/$fileName.png').create();
        await thumbnail.writeAsBytes(thumbnailData);

        final video = Video(
          path: newVideoFile.path.substring(dir.path.length + 1),
          thumbnailPath: thumbnail.path.substring(dir.path.length + 1),
        );

        getIt<VideoRepository>().saveVideo(video);

        return _VideoProcessingResult(success: true);
      } on FileSystemException catch (err) {
        if (err.osError?.errorCode == 28) {
          return _OutOfMenory();
        }

        return _VideoProcessingResult(
          success: false,
          errorMessage: 'Failed to process video: $newPath, error: $err',
        );
      } catch (e) {
        return _VideoProcessingResult(
          success: false,
          errorMessage: 'Failed to process video: $newPath, error: $e',
        );
      }
    }));

    hideLoading();

    var successCount = 0;
    var errorCount = 0;
    var outOfMemory = false;

    for (final result in processingResults) {
      if (result.success) {
        successCount++;
      } else {
        errorCount++;
      }

      if (result is _OutOfMenory) {
        outOfMemory = true;
      }
    }

    if (errorCount > 0) {
      BotToast.showText(
        text: 'Imported $successCount videos, failed to import $errorCount videos.',
      );

      if (outOfMemory) {
        BotToast.showText(
          text: 'Out of storage space, please free up some space and try again.',
        );
      }
    } else {
      BotToast.showText(text: 'Imported $successCount videos.');
    }
  }
}

class _VideoProcessingResult {
  final bool success;
  final String? errorMessage;

  _VideoProcessingResult({required this.success, this.errorMessage});
}

class _OutOfMenory extends _VideoProcessingResult {
  _OutOfMenory() : super(success: false, errorMessage: 'Out of storage space');
}
