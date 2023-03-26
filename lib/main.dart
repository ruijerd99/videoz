import 'package:bot_toast/bot_toast.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:videoz/screen/nav_screen/nav_screen.dart';

import 'data/injector.dart';
import 'data/model/video/video.dart';
import 'data/repository/video/video_repository.dart';
import 'utils/common_func.dart';

ValueNotifier<bool> isLoop = ValueNotifier<bool>(false);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Injector.setup();
  final videos = await getIt<VideoRepository>().getAllVideos();
  videos.shuffle();

  isLoop.value = await isLooping();

  runApp(MainApp(videos: videos));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key, required this.videos});
  final List<Video> videos;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: FlexThemeData.light(
        scheme: FlexScheme.brandBlue,
        surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
        blendLevel: 9,
        subThemesData: const FlexSubThemesData(
          blendOnLevel: 10,
          blendOnColors: false,
        ),
        visualDensity: FlexColorScheme.comfortablePlatformDensity,
        useMaterial3: true,
        swapLegacyOnMaterial3: true,
        // To use the playground font, add GoogleFonts package and uncomment
        // fontFamily: GoogleFonts.notoSans().fontFamily,
      ),
      darkTheme: FlexThemeData.dark(
        scheme: FlexScheme.brandBlue,
        surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
        blendLevel: 15,
        darkIsTrueBlack: true,
        subThemesData: const FlexSubThemesData(
          blendOnLevel: 20,
        ),
        visualDensity: FlexColorScheme.comfortablePlatformDensity,
        useMaterial3: true,
        swapLegacyOnMaterial3: true,
        // To use the Playground font, add GoogleFonts package and uncomment
        // fontFamily: GoogleFonts.notoSans().fontFamily,
      ),
      themeMode: ThemeMode.dark,
      builder: BotToastInit(),
      navigatorObservers: [BotToastNavigatorObserver()],
      home: NavScreen(videos: videos),
    );
  }
}
