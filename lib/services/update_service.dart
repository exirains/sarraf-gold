import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class UpdateInfo {
  final String version;
  final String apkUrl;
  final List<String> notes;
  final String appName;
  final int buildNumber;

  UpdateInfo({
    required this.version,
    required this.apkUrl,
    required this.notes,
    this.appName = "Sarraf Gold",
    this.buildNumber = 1,
  });

  factory UpdateInfo.fromJson(Map<String, dynamic> json) {
    return UpdateInfo(
      version: json["version"]?.toString() ?? "0.0.0",
      apkUrl: json["apk_url"]?.toString() ?? "",
      notes: List<String>.from(json["notes"] ?? []),
      appName: json["app_name"]?.toString() ?? "Sarraf Gold",
      buildNumber: json["build_number"] ?? 1,
    );
  }
}

class UpdateService {
  static UpdateInfo? localInfo;

  static Future<void> initLocalVersion() async {
    try {
      final String jsonStr = await rootBundle.loadString('update.json');

      final data = jsonDecode(jsonStr);

      localInfo = UpdateInfo.fromJson(data);

      debugPrint(
        "Local Version Loaded: ${localInfo?.version}",
      );
    } catch (e) {
      debugPrint(
        "Error loading local version: $e",
      );
    }
  }


  static Future<UpdateInfo?> checkUpdate() async {

    // Web does not need APK update checks
    if (kIsWeb) {
      debugPrint(
        "Update check skipped: Running on Web",
      );
      return null;
    }


    if (localInfo == null) {
      await initLocalVersion();
    }


    try {
      final response = await http
          .get(
        Uri.parse(
          "https://raw.githubusercontent.com/exirains/sarraf-gold/main/update.json",
        ),
      )
          .timeout(
        const Duration(seconds: 10),
      );


      if (response.statusCode != 200) {
        debugPrint(
          "Update check failed: ${response.statusCode}",
        );
        return null;
      }


      final data = jsonDecode(response.body);

      final remoteInfo = UpdateInfo.fromJson(data);


      final currentVersion =
          localInfo?.version ?? "0.0.0";


      debugPrint(
        "Update check: Current v$currentVersion | Remote v${remoteInfo.version}",
      );


      if (_shouldUpdate(
        currentVersion,
        remoteInfo.version,
      )) {
        return remoteInfo;
      }

    } catch (e) {

      debugPrint(
        "Update check error: $e",
      );

    }


    return null;
  }



  static bool _shouldUpdate(
      String local,
      String remote,
      ) {

    try {

      final localParts =
      local.split('.').map(int.parse).toList();

      final remoteParts =
      remote.split('.').map(int.parse).toList();


      for (int i = 0; i < remoteParts.length; i++) {

        if (i >= localParts.length) {
          return true;
        }


        if (remoteParts[i] > localParts[i]) {
          return true;
        }


        if (remoteParts[i] < localParts[i]) {
          return false;
        }

      }

    } catch (_) {

      return remote != local;

    }


    return false;
  }
}