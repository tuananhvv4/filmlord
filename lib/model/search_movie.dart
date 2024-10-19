import 'detail_movie.dart';

class SearchMovie {
  int? total;
  String? start;
  int? end;
  List<SearchMovieItem>? data;

  SearchMovie({this.total, this.start, this.end, this.data});

  SearchMovie.fromJson(Map<String, dynamic> json) {
    total = json['total'];
    start = json['start'];
    end = json['end'];
    if (json['data'] != null) {
      data = <SearchMovieItem>[];
      json['data'].forEach((v) {
        data!.add(new SearchMovieItem.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['total'] = this.total;
    data['start'] = this.start;
    data['end'] = this.end;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class SearchMovieItem {
  Modified? modified;
  String? sId;
  String? name;
  String? slug;
  String? originName;
  String? type;
  String? posterUrl;
  String? thumbUrl;
  bool? subDocquyen;
  bool? chieurap;
  String? time;
  String? episodeCurrent;
  String? quality;
  String? lang;
  int? year;
  List<Category>? category;
  List<Country>? country;

  SearchMovieItem(
      {this.modified,
        this.sId,
        this.name,
        this.slug,
        this.originName,
        this.type,
        this.posterUrl,
        this.thumbUrl,
        this.subDocquyen,
        this.chieurap,
        this.time,
        this.episodeCurrent,
        this.quality,
        this.lang,
        this.year,
        this.category,
        this.country});

  SearchMovieItem.fromJson(Map<String, dynamic> json) {
    modified = json['modified'] != null
        ? new Modified.fromJson(json['modified'])
        : null;
    sId = json['_id'];
    name = json['name'];
    slug = json['slug'];
    originName = json['origin_name'];
    type = json['type'];
    posterUrl = json['poster_url'];
    thumbUrl = json['thumb_url'];
    subDocquyen = json['sub_docquyen'];
    chieurap = json['chieurap'];
    time = json['time'];
    episodeCurrent = json['episode_current'];
    quality = json['quality'];
    lang = json['lang'];
    year = json['year'];
    if (json['category'] != null) {
      category = <Category>[];
      json['category'].forEach((v) {
        category!.add(new Category.fromJson(v));
      });
    }
    if (json['country'] != null) {
      country = <Country>[];
      json['country'].forEach((v) {
        country!.add(new Country.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.modified != null) {
      data['modified'] = this.modified!.toJson();
    }
    data['_id'] = this.sId;
    data['name'] = this.name;
    data['slug'] = this.slug;
    data['origin_name'] = this.originName;
    data['type'] = this.type;
    data['poster_url'] = this.posterUrl;
    data['thumb_url'] = this.thumbUrl;
    data['sub_docquyen'] = this.subDocquyen;
    data['chieurap'] = this.chieurap;
    data['time'] = this.time;
    data['episode_current'] = this.episodeCurrent;
    data['quality'] = this.quality;
    data['lang'] = this.lang;
    data['year'] = this.year;
    if (this.category != null) {
      data['category'] = this.category!.map((v) => v.toJson()).toList();
    }
    if (this.country != null) {
      data['country'] = this.country!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Modified {
  String? time;

  Modified({this.time});

  Modified.fromJson(Map<String, dynamic> json) {
    time = json['time'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['time'] = this.time;
    return data;
  }
}

class Category {
  String? id;
  String? name;
  String? slug;

  Category({this.id, this.name, this.slug});

  Category.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    slug = json['slug'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['slug'] = this.slug;
    return data;
  }
}
