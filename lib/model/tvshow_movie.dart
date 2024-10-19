import 'detail_movie.dart';

class TvShowsMovies {
  String? status;
  String? msg;
  Data? data;

  TvShowsMovies({this.status, this.msg, this.data});

  TvShowsMovies.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    msg = json['msg'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['msg'] = this.msg;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  SeoOnPage? seoOnPage;
  List<BreadCrumb>? breadCrumb;
  String? titlePage;
  List<TvShowsItems>? items;
  Params? params;
  String? typeList;
  String? aPPDOMAINFRONTEND;
  String? aPPDOMAINCDNIMAGE;

  Data(
      {this.seoOnPage,
        this.breadCrumb,
        this.titlePage,
        this.items,
        this.params,
        this.typeList,
        this.aPPDOMAINFRONTEND,
        this.aPPDOMAINCDNIMAGE});

  Data.fromJson(Map<String, dynamic> json) {
    seoOnPage = json['seoOnPage'] != null
        ? new SeoOnPage.fromJson(json['seoOnPage'])
        : null;
    if (json['breadCrumb'] != null) {
      breadCrumb = <BreadCrumb>[];
      json['breadCrumb'].forEach((v) {
        breadCrumb!.add(new BreadCrumb.fromJson(v));
      });
    }
    titlePage = json['titlePage'];
    if (json['items'] != null) {
      items = <TvShowsItems>[];
      json['items'].forEach((v) {
        items!.add(new TvShowsItems.fromJson(v));
      });
    }
    params =
    json['params'] != null ? new Params.fromJson(json['params']) : null;
    typeList = json['type_list'];
    aPPDOMAINFRONTEND = json['APP_DOMAIN_FRONTEND'];
    aPPDOMAINCDNIMAGE = json['APP_DOMAIN_CDN_IMAGE'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.seoOnPage != null) {
      data['seoOnPage'] = this.seoOnPage!.toJson();
    }
    if (this.breadCrumb != null) {
      data['breadCrumb'] = this.breadCrumb!.map((v) => v.toJson()).toList();
    }
    data['titlePage'] = this.titlePage;
    if (this.items != null) {
      data['items'] = this.items!.map((v) => v.toJson()).toList();
    }
    if (this.params != null) {
      data['params'] = this.params!.toJson();
    }
    data['type_list'] = this.typeList;
    data['APP_DOMAIN_FRONTEND'] = this.aPPDOMAINFRONTEND;
    data['APP_DOMAIN_CDN_IMAGE'] = this.aPPDOMAINCDNIMAGE;
    return data;
  }
}

class SeoOnPage {
  String? ogType;
  String? titleHead;
  String? descriptionHead;
  List<String>? ogImage;
  String? ogUrl;

  SeoOnPage(
      {this.ogType,
        this.titleHead,
        this.descriptionHead,
        this.ogImage,
        this.ogUrl});

  SeoOnPage.fromJson(Map<String, dynamic> json) {
    ogType = json['og_type'];
    titleHead = json['titleHead'];
    descriptionHead = json['descriptionHead'];
    ogImage = json['og_image'].cast<String>();
    ogUrl = json['og_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['og_type'] = this.ogType;
    data['titleHead'] = this.titleHead;
    data['descriptionHead'] = this.descriptionHead;
    data['og_image'] = this.ogImage;
    data['og_url'] = this.ogUrl;
    return data;
  }
}

class BreadCrumb {
  String? name;
  String? slug;
  bool? isCurrent;
  int? position;

  BreadCrumb({this.name, this.slug, this.isCurrent, this.position});

  BreadCrumb.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    slug = json['slug'];
    isCurrent = json['isCurrent'];
    position = json['position'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['slug'] = this.slug;
    data['isCurrent'] = this.isCurrent;
    data['position'] = this.position;
    return data;
  }
}

class TvShowsItems {
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

  TvShowsItems(
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

  TvShowsItems.fromJson(Map<String, dynamic> json) {
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

class Params {
  String? typeSlug;
  List<String>? filterCategory;
  List<String>? filterCountry;
  String? filterYear;
  String? filterType;
  String? sortField;
  String? sortType;
  Pagination? pagination;

  Params(
      {this.typeSlug,
        this.filterCategory,
        this.filterCountry,
        this.filterYear,
        this.filterType,
        this.sortField,
        this.sortType,
        this.pagination});

  Params.fromJson(Map<String, dynamic> json) {
    typeSlug = json['type_slug'];
    filterCategory = json['filterCategory'].cast<String>();
    filterCountry = json['filterCountry'].cast<String>();
    filterYear = json['filterYear'];
    filterType = json['filterType'];
    sortField = json['sortField'];
    sortType = json['sortType'];
    pagination = json['pagination'] != null
        ? new Pagination.fromJson(json['pagination'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type_slug'] = this.typeSlug;
    data['filterCategory'] = this.filterCategory;
    data['filterCountry'] = this.filterCountry;
    data['filterYear'] = this.filterYear;
    data['filterType'] = this.filterType;
    data['sortField'] = this.sortField;
    data['sortType'] = this.sortType;
    if (this.pagination != null) {
      data['pagination'] = this.pagination!.toJson();
    }
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
