import 'package:flutter/material.dart';

class ErrorPage extends StatelessWidget {
  final Object error;

  const ErrorPage(this.error, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          error.toString(),
          style: Theme.of(context)
              .textTheme
              .bodyText1!
              .copyWith(color: Theme.of(context).colorScheme.error),
        ),
      ),
    );
  }
}
