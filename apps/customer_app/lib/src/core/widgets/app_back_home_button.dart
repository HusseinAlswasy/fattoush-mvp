import 'package:flutter/material.dart';

class AppBackHomeButton extends StatelessWidget {
  const AppBackHomeButton({
    super.key,
    required this.homeRouteName,
  });

  final String homeRouteName;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Back',
      icon: const Icon(Icons.arrow_back_rounded),
      onPressed: () {
        final navigator = Navigator.of(context);
        if (navigator.canPop()) {
          navigator.pop();
          return;
        }

        navigator.pushReplacementNamed(homeRouteName);
      },
    );
  }
}
