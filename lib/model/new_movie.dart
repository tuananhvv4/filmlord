class FilmList {
  bool? status;
  List<NewMovieItems>? items;
  Pagination? pagination;

  FilmList({this.status, this.items, this.pagination});

  FilmList.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['items'] != null) {
      items = <NewMovieItems>[];
      json['items'].forEach((v) {
        items!.add(new NewMovieItems.fromJson(v));
      });
    }
    pagination = json['pagination'] != null
        ? new Pagination.fromJson(json['pagination'])
        : null;
  }



  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    if (this.items != null) {
      data['items'] = this.items!.map((v) => v.toJson()).toList();
    }
    if (this.pagination != null) {
      data['pagination'] = this.pagination!.toJson();
    }
    return data;
  }
}



class NewMovieItems {
  Modified? modified;
  String? sId;
  String? name;
  String? slug;
  String? originName;
  String? posterUrl;
  String? thumbUrl;
  int? year;

  NewMovieItems(
      {this.modified,
        this.sId,
        this.name,
        this.slug,
        this.originName,
        this.posterUrl,
        this.thumbUrl,
        this.year});

  NewMovieItems.fromJson(Map<String, dynamic> json) {
    modified = json['modified'] != null
        ? new Modified.fromJson(json['modified'])
        : null;
    sId = json['_id'];
    name = json['name'];
    slug = json['slug'];
    originName = json['origin_name'];
    posterUrl = json['poster_url'];
    thumbUrl = json['thumb_url'];
    year = json['year'];
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
    data['poster_url'] = this.posterUrl;
    data['thumb_url'] = this.thumbUrl;
    data['year'] = this.year;
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

class Pagination {
  int? totalItems;
  int? totalItemsPerPage;
  int? currentPage;
  int? totalPages;

  Pagination(
      {this.totalItems,
        this.totalItemsPerPage,
        this.currentPage,
        this.totalPages});

  Pagination.fromJson(Map<String, dynamic> json) {
    totalItems = json['totalItems'];
    totalItemsPerPage = json['totalItemsPerPage'];
    currentPage = json['currentPage'];
    totalPages = json['totalPages'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['totalItems'] = this.totalItems;
    data['totalItemsPerPage'] = this.totalItemsPerPage;
    data['currentPage'] = this.currentPage;
    data['totalPages'] = this.totalPages;
    return data;
  }
}
