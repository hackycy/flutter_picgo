import 'dart:io';
import 'package:flutter_picgo/model/uploaded.dart';
import 'package:flutter_picgo/resources/table_name_keys.dart';
import 'package:flutter_picgo/utils/shared_preferences.dart';
import 'package:flutter_picgo/utils/sql.dart';
import 'package:flutter_picgo/utils/strategy/image_upload_strategy.dart';

/// 图像上传类
class ImageUpload {
  ImageUploadStrategy _strategy;

  ImageUpload(this._strategy);

  Future<Uploaded> delete(Uploaded uploaded) {
    return _strategy.delete(uploaded);
  }

  Future<Uploaded> upload(File file, String renameImage) {
    return _strategy.upload(file, renameImage);
  }

  /// 获取默认图床类型
  static Future<String> getDefaultPB() async {
    var sp = await SpUtil.getInstance();
    String pbType = sp.getDefaultPB();
    return pbType;
  }

  /// 设置默认图床
  static Future setDefaultPB(String type) async {
    var sp = await SpUtil.getInstance();
    if (sp.getDefaultPB() != type) {
      sp.setDefaultPB(type);
    }
  }

  /// 保存图床配置
  static Future<int> savePBConfig(String type, String config) async {
    var sql = Sql.setTable(TABLE_NAME_PBSETTING);
    int raw = await sql.rawUpdate('config = ? WHERE type = ?', [config, type]);
    return raw;
  }

  /// 获取当前图床配置
  static Future<String> getPBConfig(String type) async {
    var sql = Sql.setTable(TABLE_NAME_PBSETTING);
    var pbsettingRow = await sql.getBySql('type = ?', [type]);
    if (pbsettingRow != null && pbsettingRow.length > 0) {
      return pbsettingRow.first["config"];
    }
    return null;
  }

  /// 获取图床名称
  static Future<String> getPBName(String type) async {
    var sql = Sql.setTable(TABLE_NAME_PBSETTING);
    var pbsettingRow = (await sql.getBySql('type = ?', [type]));
    if (pbsettingRow != null && pbsettingRow.length > 0) {
      return pbsettingRow.first["name"];
    }
    return null;
  }

  /// 保存已上传项
  static Future<int> saveUploadedItem(Uploaded item) async {
    var sql = Sql.setTable(TABLE_NAME_UPLOADED);
    return await sql.rawInsert('(path, type, info)  VALUES(?, ?, ?)',
        [item.path, item.type, item.info]);
  }

  /// 删除已上传的本地数据库项
  static Future<int> deleteUploadedItem(Uploaded item) async {
    var sql = Sql.setTable(TABLE_NAME_UPLOADED);
    var result = await sql.rawDelete('id = ?', [item.id]);
    return result;
  }

  /// 获取已上传项的信息
  static Future<String> getUploadedItemInfo(int id) async {
    var sql = Sql.setTable(TABLE_NAME_UPLOADED);
    return (await sql.getBySql('id = ?', [id]))?.first["info"];
  }

}