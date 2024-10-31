import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
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

  // Lấy danh sách từ SharedPreferences
  static Future<List<Data>> getData(String category) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? personList = prefs.getStringList(category);
    if (personList != null) {
      return personList.map((item) => Data.fromJson(jsonDecode(item))).toList();
    }
    return [];
  }

  static Future<void> clearAllData() async {
    List<String> searchHistory = [];
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    searchHistory =
        prefs.getStringList('searchHistory') ?? []; // lưu lại lịch sử tìm kiếm
    await prefs.clear(); // Xóa tất cả dữ liệu đã lưu
    await prefs.setStringList('searchHistory', searchHistory);
  }

  static String formatElapsedTime(Timestamp commentTime) {
    final currentTime = DateTime.now();
    final commentDateTime = commentTime.toDate();
    final difference = currentTime.difference(commentDateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} phút trước';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} giờ trước';
    } else {
      return '${difference.inDays} ngày trước';
    }
  }

  static String filterText(String input) {
    String noHtmlTags = input.replaceAll(RegExp(r'<[^>]+>'), '');
    String filteredText = noHtmlTags.replaceAll(
      RegExp(
          r'[^a-zA-Z0-9ÀÁÂÃÈÉẺÊÌÍÒÓÔÕÙÚĂĐĨŨƯƠÝYàáâãèéêìíòóôõùúăđĩũươẠ-ỹýy.,!? ]'),
      '',
    );
    return filteredText;
  }
}
