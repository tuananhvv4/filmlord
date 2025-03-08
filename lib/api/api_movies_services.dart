import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/data_movie.dart';

class ApiServices {
  static String urlNewMovies =
      'https://phimapi.com/danh-sach/phim-moi-cap-nhat?page=1';
  static String urlSingleMovies =
      'https://phimapi.com/v1/api/danh-sach/phim-le';
  static String urlSeriesMovies =
      'https://phimapi.com/v1/api/danh-sach/phim-bo';
  static String urlCartoonMovies =
      'https://phimapi.com/v1/api/danh-sach/hoat-hinh';
  static String urlTvShows = 'https://phimapi.com/v1/api/danh-sach/tv-shows';

  static List<String> originalCase = [
    'Âm Nhạc',
    'Bí Ẩn',
    'Chiến Tranh',
    'Chính Kịch',
    'Cổ Trang',
    'Gia Đình',
    'Hài Hước',
    'Hành Động',
    'Hình Sự',
    'Học Đường',
    'Khoa Học',
    'Kinh Dị',
    'Kinh Điển',
    'Phiêu Lưu',
    'Phim 18+',
    'Tài Liệu',
    'Tâm Lý',
    'Thần Thoại',
    'Thể Thao',
    'Tình Cảm',
    'Viễn Tưởng',
    'Võ Thuật',
  ];

  static List<String> upperCase = [
    'ÂM NHẠC',
    'BÍ ẨN',
    'CHIẾN TRANH',
    'CHÍNH KỊCH',
    'CỔ TRANG',
    'GIA ĐÌNH',
    'HÀI HƯỚC',
    'HÀNH ĐỘNG',
    'HÌNH SỰ',
    'HỌC ĐƯỜNG',
    'KHOA HỌC',
    'KINH DỊ',
    'KINH ĐIỂN',
    'PHIÊU LƯU',
    'PHIM 18+',
    'TÀI LIỆU',
    'TÂM LÝ',
    'THẦN THOẠI',
    'THỂ THAO',
    'TÌNH CẢM',
    'VIỄN TƯỞNG',
    'VÕ THUẬT',
  ];

  static List<String> slugCase = [
    'am-nhac',
    'bi-an',
    'chien-tranh',
    'chinh-kich',
    'co-trang',
    'gia-dinh',
    'hai-huoc',
    'hanh-dong',
    'hinh-su',
    'hoc-duong',
    'khoa-hoc',
    'kinh-di',
    'kinh-dien',
    'phieu-luu',
    'phim-18',
    'tai-lieu',
    'tam-ly',
    'than-thoai',
    'the-thao',
    'tinh-cam',
    'vien-tuong',
    'vo-thuat',
  ];

  static Future<List<Data>> fetchMoviesData(String category) async {
    String apiURL = '';
    switch (category) {
      case 'phim-le':
        apiURL = urlSingleMovies;
        break;
      case 'phim-bo':
        apiURL = urlSeriesMovies;
        break;
      case 'hoat-hinh':
        apiURL = urlCartoonMovies;
        break;
      case 'tv-shows':
        apiURL = urlTvShows;
        break;
    }
    // log(category);
    List<Data> data = [];
    var responseData = await http.get(Uri.parse(apiURL));
    if (responseData.statusCode == 200) {
      var moviesJsonData = jsonDecode(responseData.body);
      // log(moviesJsonData.toString());
      for (var item in moviesJsonData['data']['items']) {
        Data movie = Data.fromJson(item);
        data.add(movie);
      }
      // data = moviesJsonData['data']['items']
      //     .map((item) => Data.fromJson(item))
      //     .toList();
      return data;
    }
    return data;
  }

  static Future<List<Data>> fetchNewMoviesData(String category) async {
    List<Data> data = [];
    var responseData = await http.get(Uri.parse(urlNewMovies));
    if (responseData.statusCode == 200) {
      var moviesJsonData = jsonDecode(responseData.body);
      // setCacheData(category,jsonEncode(moviesJsonData));
      for (var item in moviesJsonData['items']) {
        var movie = Data.fromJson(item);
        data.add(movie);
      }
      return data;
    }
    return data;
  }

  static Future<String> getMovieDetail(String slug) async {
    var response = await http.get(Uri.parse('https://phimapi.com/phim/$slug'));
    if (response.statusCode == 200) {
      return response.body;
    }
    return '';
  }
}
