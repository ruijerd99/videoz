import 'package:isar/isar.dart';
import 'package:get_it/get_it.dart';
import 'package:path_provider/path_provider.dart';

import 'model/video/video.dart';
import 'repository/video/video_repository.dart';

import 'data_provider/video/video_local_data_source.dart';

final getIt = GetIt.instance;

late String documentDir;

class Injector {
  Injector._internal();

  static Future<void> setup() async {
    final isar = await Isar.open([VideoSchema]);
    getIt.registerSingleton<Isar>(isar);

    documentDir = await getApplicationDocumentsDirectory().then((value) => value.path);

    getIt.registerFactory<VideoLocalDataSource>(
      () => VideoLocalDataSourceImpl(getIt<Isar>()),
    );

    getIt.registerFactory<VideoRepository>(
      () => VideoRepositoryImpl(
        videoLocalDataSource: getIt<VideoLocalDataSource>(),
      ),
    );
  }
}
