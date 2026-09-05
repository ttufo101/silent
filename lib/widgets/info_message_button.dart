import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/theme.dart';
import 'package:flutter/material.dart';

class InfoMessageButton extends StatelessWidget {
  const InfoMessageButton({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return CommonMinIconButtonTheme(
      child: IconButton(
        onPressed: () {
          globalState.showMessage(message: TextSpan(text: message));
        },
        icon: Icon(Icons.info, size: 20.ap, color: context.colorScheme.error),
      ),
    );
  }
}
