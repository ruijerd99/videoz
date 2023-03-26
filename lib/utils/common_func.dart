import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';

void showLoading() {
  BotToast.showCustomLoading(
    clickClose: true,
    toastBuilder: (cancelFunc) {
      return Container(
        width: 150,
        height: 150,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: const SpinKitWave(
          color: Colors.white,
          size: 50.0,
        ),
      );
    },
  );
}

void hideLoading() {
  BotToast.closeAllLoading();
}


Future<bool> isLooping() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getInt('setting') == 0;
}