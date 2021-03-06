import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_picgo/api/gitee_api.dart';
import 'package:flutter_picgo/model/gitee_config.dart';
import 'package:flutter_picgo/model/uploaded.dart';
import 'package:flutter_picgo/resources/pb_type_keys.dart';
import 'package:flutter_picgo/utils/encrypt.dart';
import 'package:flutter_picgo/utils/image_upload.dart';
import 'package:flutter_picgo/utils/strings.dart';
import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:flutter_picgo/utils/strategy/image_upload_strategy.dart';

class GiteeImageUpload implements ImageUploadStrategy {
  static const UPLOAD_COMMIT_MESSAGE = "Upload by Flutter-PicGo";
  static const DELETE_COMMIT_MESSAGE = "Delete by Flutter-PicGo";

  @override
  Future<Uploaded> delete(Uploaded uploaded) async {
    GiteeUploadedInfo info;
    try {
      info = GiteeUploadedInfo.fromJson(json.decode(uploaded.info));
    } catch (e) {}
    if (info != null) {
      String realUrl =
          path.joinAll(['repos', info.ownerrepo, 'contents', info.path]);
      Map<String, dynamic> mapData = {
        "message": DELETE_COMMIT_MESSAGE,
        "sha": info.sha,
      };
      if (!isBlank(info.branch)) {
        mapData["branch"] = info.branch;
      }
      await GiteeApi.deleteFile(realUrl, mapData);
    }
    return uploaded;
  }

  @override
  Future<Uploaded> upload(File file, String renameImage) async {
    try {
      String configStr = await ImageUploadUtils.getPBConfig(PBTypeKeys.gitee);
      if (isBlank(configStr)) {
        throw GiteeError(error: '读取配置文件错误！请重试');
      }
      GiteeConfig config = GiteeConfig.fromJson(json.decode(configStr));
      String realUrl = path.joinAll([
        'repos',
        config.owner,
        config.repo,
        'contents',
        config.path,
        renameImage
      ]);
      Map<String, dynamic> mapData = {
        "message": UPLOAD_COMMIT_MESSAGE,
        "content": await EncryptUtils.image2Base64(file.path)
      };
      if (!isBlank(config.branch)) {
        mapData["branch"] = config.branch;
      }
      var result = await GiteeApi.createFile(realUrl, mapData);
      String imagePath = result["content"]["path"];
      String downloadUrl = result["content"]["download_url"];
      String sha = result["content"]["sha"];
      String imageUrl = config.customUrl == null || config.customUrl == ''
          ? downloadUrl
          : '${path.joinAll([config.customUrl, imagePath])}';
      var uploadedItem = Uploaded(-1, imageUrl, PBTypeKeys.gitee,
          info: json.encode(GiteeUploadedInfo(
              path: imagePath,
              sha: sha,
              branch: config.branch,
              ownerrepo: '${config.owner}/${config.repo}')));
      await ImageUploadUtils.saveUploadedItem(uploadedItem);
      return uploadedItem;
    } on DioError catch (e) {
      if (e.type == DioErrorType.response &&
          e.error.toString().indexOf('400') > 0) {
        throw GiteeError(error: '文件已存在！');
      } else {
        throw e;
      }
    }
  }
}

/// GithubError describes the error info  when request failed.
class GiteeError implements Exception {
  GiteeError({
    this.error,
  });

  dynamic error;

  String get message => (error?.toString() ?? '');

  @override
  String toString() {
    var msg = 'GithubError $message';
    if (error is Error) {
      msg += '\n${error.stackTrace}';
    }
    return msg;
  }
}

class GiteeUploadedInfo {
  String sha;
  String branch;
  String path;
  String ownerrepo;

  GiteeUploadedInfo({this.sha, this.branch, this.path, this.ownerrepo});

  GiteeUploadedInfo.fromJson(Map<String, dynamic> json) {
    sha = json['sha'];
    branch = json['branch'];
    path = json['path'];
    ownerrepo = json['ownerrepo'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['sha'] = this.sha;
    data['branch'] = this.branch;
    data['path'] = this.path;
    data['ownerrepo'] = this.ownerrepo;
    return data;
  }
}
