import 'package:flutter/material.dart';

class LoadingDialog extends StatelessWidget {
  final String text;
  static void show(BuildContext context, {Key key, String text}) => showDialog<void>(
        context: context,
        useRootNavigator: false,
        barrierDismissible: false,
        builder: (_) => LoadingDialog(key: key, text: text,),
      ).then((_) => FocusScope.of(context).requestFocus(FocusNode()));

  static void hide(BuildContext context) => Navigator.pop(context);

  LoadingDialog({Key key, this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Center(
          child: Card(
        child: Center(
          heightFactor: 0.15,
          widthFactor: 1.2,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
              Container(
                width: 80,
                height: 80,
                padding: EdgeInsets.all(12.0),
                child: CircularProgressIndicator(),
              ),
              Text(text ?? 'Loading...')
            ])),
      )),
    );
  }
}
