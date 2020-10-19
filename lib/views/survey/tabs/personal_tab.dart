import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prapare/strings.dart';
import 'package:prapare/views/survey/tabs/toggle_tab_checked.dart';

class PersonalTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = context.textTheme;
    return Column(
      children: [
        Center(
          child: Text(
            S.TITLE_PERSONAL,
            style: textTheme.headline5,
            textAlign: TextAlign.center,
          ),
        ),
        ToggleTabChecked()
      ],
    );
  }
}
