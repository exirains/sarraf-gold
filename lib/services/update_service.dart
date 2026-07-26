import 'dart:convert';
import 'package:http/http.dart' as http;
import '../version.dart';

class UpdateInfo {
  final String version;
  final String apkUrl;
  final String notes;

  UpdateInfo({
    required this.version,
    required this.apkUrl,
    required this.notes,
  });
}


class UpdateService {

  static Future<UpdateInfo?> checkUpdate() async {

    final response = await http.get(
        Uri.parse(
            "https://raw.githubusercontent.com/exirains/sarraf-gold/main/update.json"
        ));

    if(response.statusCode != 200){
      return null;
    }


    final data=jsonDecode(response.body);


    if(data["version"] != appVersion){

      return UpdateInfo(
        version:data["version"],
        apkUrl:data["apk_url"],
        notes:data["notes"],
      );

    }


    return null;

  }

}