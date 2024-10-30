import 'dart:convert';

import 'package:movies_app/model/data_movie.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Helper {
  static String handleUrl(String url) {
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      return 'https://www.kkphim.vip/$url';
    }
    // Nếu đã có 'http://' hoặc 'https://', trả về URL gốc
    return url;
  }

  // Lưu danh sách dữ liệu vào bộ nhớ
  static Future<void> saveData(String category, List<Data> data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> personList =
        data.map((person) => jsonEncode(person.toJson())).toList();
    prefs.setStringList(category, personList);
    prefs.setInt('$category-currentPage', 1); // lưu lại trang phim đã tải
  }
}
