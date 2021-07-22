import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_media_gallery_saver/flutter_media_gallery_saver.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class Menu extends StatefulWidget {
  Menu({Key? key}) : super(key: key);

  @override
  _MenuState createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  GlobalKey _globalKey = GlobalKey();
  int index = 0;
  String? link;
  final linkController = TextEditingController();

  var progress = '0';

  @override
  void initState() {
    super.initState();
    _requestPermission();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _requestPermission() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
    ].request();

    final info = statuses[Permission.storage].toString();
    print(info);
    _toastInfo(info);
  }

  @override
  Widget build(BuildContext context) {
    link = linkController.text;

    return Scaffold(
      appBar: AppBar(
        title: Text('Video Link Download'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              RepaintBoundary(
                key: _globalKey,
                child: Container(
                  width: 200,
                  height: 200,
                  child: Center(
                    child: new TextFormField(
                      controller: linkController,
                      textInputAction: TextInputAction.done,
                      decoration: new InputDecoration(
                        labelText: "Masukkan link url",
                        labelStyle: TextStyle(
                          color: Colors.grey,
                        ),
                        // hintText: '0',
                        fillColor: Colors.white,
                        border: new OutlineInputBorder(
                          borderRadius: new BorderRadius.circular(8.0),
                          borderSide:
                              new BorderSide(color: Colors.blue.shade800),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.only(top: 15),
                child: TextButton(
                  onPressed: _saveVideo,
                  child: Text("Simpan Video"),
                ),
                width: 200,
              ),
              Container(
                padding: EdgeInsets.only(top: 15),
                child: TextButton(
                  onPressed: _saveLargerVideo,
                  child: Text("Simpan Video--$progress"),
                ),
                width: 200,
              ),
            ],
          ),
        ),
      ),
    );
  }

  _saveVideo() async {
    var appDocDir = await getTemporaryDirectory();
    String savePath = appDocDir.path + "/temp.mp4";
    if (File(savePath).existsSync()) {
      final result = await FlutterGallerySaver.saveVideo(savePath);
      print(result);
      _toastInfo("$result");
    } else {
      String fileUrl = linkController.text;
      await Dio().download(fileUrl, savePath,
          onReceiveProgress: (count, total) {
        print((count / total * 100).toStringAsFixed(0) + "%");
      });
      final result = await FlutterGallerySaver.saveVideo(savePath);
      print(result);
      _toastInfo("$result");
    }
  }

  _saveLargerVideo() async {
    var appDocDir = await getTemporaryDirectory();
    String savePath = appDocDir.path + "/larger_temp.mp4";
    if (File(savePath).existsSync()) {
      final result = await FlutterGallerySaver.saveVideo(savePath);
      print(result);
      _toastInfo("$result");
    } else {
      String fileUrl = linkController.text;
      await Dio().download(fileUrl, savePath,
          onReceiveProgress: (count, total) {
        setState(() {
          progress = (count / total * 100).toStringAsFixed(0) + "%";
        });
        print((count / total * 100).toStringAsFixed(0) + "%");
      });
      final result = await FlutterGallerySaver.saveVideo(savePath);
      print(result);
      _toastInfo("$result");
    }
  }

  _toastInfo(String info) {
    Fluttertoast.showToast(msg: info, toastLength: Toast.LENGTH_LONG);
  }
}
