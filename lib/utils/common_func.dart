import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

showLoading() {
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

hideLoading() {
  BotToast.closeAllLoading();
}
