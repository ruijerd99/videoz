import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:videoz/main.dart';

class AnimatedToggle extends StatefulWidget {
  final String firstValue;
  final String secondValue;

  /// first value is 0 and second value is 1
  final ValueChanged<int> onToggleCallback;

  final int initialIndex;

  final Color? backgroundColor;
  final Color? buttonColor;
  final Color? textColor;

  const AnimatedToggle({
    super.key,
    required this.firstValue,
    required this.secondValue,
    required this.onToggleCallback,
    this.initialIndex = 0,
    this.backgroundColor,
    this.buttonColor,
    this.textColor,
  });

  @override
  State<AnimatedToggle> createState() => _AnimatedToggleState();
}

class _AnimatedToggleState extends State<AnimatedToggle> {
  var _currentIndex = 0;
  final _height = 40.0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final theme = Theme.of(context);
    return SizedBox(
      height: _height,
      width: width * 0.6,
      child: Stack(
        children: <Widget>[
          GestureDetector(
            onTap: () {
              _currentIndex = _currentIndex == 0 ? 1 : 0;
              widget.onToggleCallback(_currentIndex);
              setState(() {});
            },
            child: Container(
              height: 40,
              decoration: ShapeDecoration(
                color: theme.primaryColorDark,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        widget.firstValue,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        widget.secondValue,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedAlign(
            duration: const Duration(milliseconds: 250),
            curve: Curves.decelerate,
            alignment: _currentIndex == 0
                ? Alignment.centerLeft
                : Alignment.centerRight,
            child: Container(
              width: width * 0.3,
              height: 40,
              decoration: ShapeDecoration(
                color: theme.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                shadows: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              alignment: Alignment.center,
              child: Text(
                _currentIndex == 0 ? widget.firstValue : widget.secondValue,
                style: TextStyle(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SettingView extends StatefulWidget {
  const SettingView({super.key});

  @override
  State<SettingView> createState() => _SettingViewState();
}

class _SettingViewState extends State<SettingView> {
  @override
  Widget build(BuildContext context) {
    return AnimatedToggle(
      onToggleCallback: (value) {
        _onSaveSettings(value);
      },
      firstValue: 'Loop',
      secondValue: 'Auto next',
      initialIndex: isLoop.value ? 0 : 1,
    );
  }

  Future<void> _onSaveSettings(int value) async {
    final prefs = await SharedPreferences.getInstance();

    prefs.setInt('setting', value);
    isLoop.value = value == 0;
  }
}
