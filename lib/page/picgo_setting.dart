import 'package:flutter/material.dart';

class PicGoSettingPage extends StatelessWidget {

  static const routeName = '/setting/picgo';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PicGo设置'),
        centerTitle: true,
      ),
    );
  }

}