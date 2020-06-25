import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_picgo/utils/shared_preferences.dart';

class PicGoSettingPage extends StatefulWidget {
  @override
  _PicGoSettingPageState createState() => _PicGoSettingPageState();
}

class _PicGoSettingPageState extends State<PicGoSettingPage> {
  bool isUploadedRename = false;
  bool isTimestampRename = false;
  bool isUploadedTip = false;
  bool isForceDelete = false;

  @override
  void initState() {
    super.initState();
    SpUtil.getInstance().then((u) {
      setState(() {
        this.isUploadedRename =
            u?.getBool(SharedPreferencesKeys.settingIsUploadedRename) ?? false;
        this.isTimestampRename =
            u?.getBool(SharedPreferencesKeys.settingIsTimestampRename) ?? false;
        this.isUploadedTip =
            u?.getBool(SharedPreferencesKeys.settingIsUploadedTip) ?? false;
        this.isUploadedTip =
            u?.getBool(SharedPreferencesKeys.settingIsForceDelete) ?? false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PicGo设置'),
        centerTitle: true,
      ),
      body: Builder(
        builder: (BuildContext context) {
          return ListView(
            children: <Widget>[
              ListTile(
                title: Text('上传前重命名'),
                trailing: CupertinoSwitch(
                  value: this.isUploadedRename,
                  onChanged: (value) {
                    this._save(
                        SharedPreferencesKeys.settingIsUploadedRename, value);
                    setState(() {
                      this.isUploadedRename = value;
                      this._showTip(context);
                    });
                  },
                ),
              ),
              ListTile(
                title: Text('时间戳重命名'),
                trailing: CupertinoSwitch(
                  value: this.isTimestampRename,
                  onChanged: (value) {
                    this._save(
                        SharedPreferencesKeys.settingIsTimestampRename, value);
                    this._showTip(context);
                    setState(() {
                      this.isTimestampRename = value;
                      this._showTip(context);
                    });
                  },
                ),
              ),
              ListTile(
                title: Text('开启上传提示'),
                trailing: CupertinoSwitch(
                  value: this.isUploadedTip,
                  onChanged: (value) {
                    this._save(
                        SharedPreferencesKeys.settingIsUploadedTip, value);
                    setState(() {
                      this.isUploadedTip = value;
                      this._showTip(context);
                    });
                  },
                ),
              ),
              ListTile(
                title: Text('仅删除本地图片'),
                trailing: CupertinoSwitch(
                  value: this.isForceDelete,
                  onChanged: (value) {
                    this._save(
                        SharedPreferencesKeys.settingIsForceDelete, value);
                    setState(() {
                      this.isForceDelete = value;
                      this._showTip(context);
                    });
                  },
                ),
              ),
              ListTile(
                title: Text('设置显示图床'),
                onTap: () {},
              ),
              ListTile(
                title: Text('检查更新'),
                onTap: () {},
              ),
            ],
          );
        },
      ),
    );
  }

  void _showTip(BuildContext context) {
    final snackBar = SnackBar(
      content: Text('保存成功'),
    );
    Scaffold.of(context).showSnackBar(snackBar);
  }

  void _save(String key, bool value) async {
    var instance = await SpUtil.getInstance();
    instance.putBool(key, value);
  }
}
