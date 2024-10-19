class filmDetail {
  bool? status;
  String? msg;
  Movie? movie;
  List<Episodes>? episodes;

  filmDetail({this.status, this.msg, this.movie, this.episodes});

  filmDetail.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    msg = json['msg'];
    movie = json['movie'] != null ? new Movie.fromJson(json['movie']) : null;
    if (json['episodes'] != null) {
      episodes = <Episodes>[];
      json['episodes'].forEach((v) {
        episodes!.add(new Episodes.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['msg'] = this.msg;
    if (this.movie != null) {
      data['movie'] = this.movie!.toJson();
    }
    if (this.episodes != null) {
      data['episodes'] = this.episodes!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Movie {
  Created? created;
  Created? modified;
  String? sId;
  String? name;
  String? slug;
  String? originName;
  String? content;
  String? type;
  String? status;
  String? posterUrl;
  String? thumbUrl;
  bool? isCopyright;
  bool? subDocquyen;
  bool? chieurap;
  String? trailerUrl;
  String? time;
  String? episodeCurrent;
  String? episodeTotal;
  String? quality;
  String? lang;
  String? notify;
  String? showtimes;
  int? year;
  int? view;
  List<String>? actor;
  List<String>? director;
  List<Category>? category;
  List<Country>? country;

  Movie(
      {this.created,
        this.modified,
        this.sId,
        this.name,
        this.slug,
        this.originName,
        this.content,
        this.type,
        this.status,
        this.posterUrl,
        this.thumbUrl,
        this.isCopyright,
        this.subDocquyen,
        this.chieurap,
        this.trailerUrl,
        this.time,
        this.episodeCurrent,
        this.episodeTotal,
        this.quality,
        this.lang,
        this.notify,
        this.showtimes,
        this.year,
        this.view,
        this.actor,
        this.director,
        this.category,
        this.country});

  Movie.fromJson(Map<String, dynamic> json) {
    created =
    json['created'] != null ? new Created.fromJson(json['created']) : null;
    modified = json['modified'] != null
        ? new Created.fromJson(json['modified'])
        : null;
    sId = json['_id'];
    name = json['name'];
    slug = json['slug'];
    originName = json['origin_name'];
    content = json['content'];
    type = json['type'];
    status = json['status'];
    posterUrl = json['poster_url'];
    thumbUrl = json['thumb_url'];
    isCopyright = json['is_copyright'];
    subDocquyen = json['sub_docquyen'];
    chieurap = json['chieurap'];
    trailerUrl = json['trailer_url'];
    time = json['time'];
    episodeCurrent = json['episode_current'];
    episodeTotal = json['episode_total'];
    quality = json['quality'];
    lang = json['lang'];
    notify = json['notify'];
    showtimes = json['showtimes'];
    year = json['year'];
    view = json['view'];
    actor = json['actor'].cast<String>();
    director = json['director'].cast<String>();
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
    if (this.created != null) {
      data['created'] = this.created!.toJson();
    }
    if (this.modified != null) {
      data['modified'] = this.modified!.toJson();
    }
    data['_id'] = this.sId;
    data['name'] = this.name;
    data['slug'] = this.slug;
    data['origin_name'] = this.originName;
    data['content'] = this.content;
    data['type'] = this.type;
    data['status'] = this.status;
    data['poster_url'] = this.posterUrl;
    data['thumb_url'] = this.thumbUrl;
    data['is_copyright'] = this.isCopyright;
    data['sub_docquyen'] = this.subDocquyen;
    data['chieurap'] = this.chieurap;
    data['trailer_url'] = this.trailerUrl;
    data['time'] = this.time;
    data['episode_current'] = this.episodeCurrent;
    data['episode_total'] = this.episodeTotal;
    data['quality'] = this.quality;
    data['lang'] = this.lang;
    data['notify'] = this.notify;
    data['showtimes'] = this.showtimes;
    data['year'] = this.year;
    data['view'] = this.view;
    data['actor'] = this.actor;
    data['director'] = this.director;
    if (this.category != null) {
      data['category'] = this.category!.map((v) => v.toJson()).toList();
    }
    if (this.country != null) {
      data['country'] = this.country!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Created {
  String? time;

  Created({this.time});

  Created.fromJson(Map<String, dynamic> json) {
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

class Episodes {
  String? serverName;
  List<ServerData>? serverData;

  Episodes({this.serverName, this.serverData});

  Episodes.fromJson(Map<String, dynamic> json) {
    serverName = json['server_name'];
    if (json['server_data'] != null) {
      serverData = <ServerData>[];
      json['server_data'].forEach((v) {
        serverData!.add(new ServerData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['server_name'] = this.serverName;
    if (this.serverData != null) {
      data['server_data'] = this.serverData!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ServerData {
  String? name;
  String? slug;
  String? filename;
  String? linkEmbed;
  String? linkM3u8;

  ServerData(
      {this.name, this.slug, this.filename, this.linkEmbed, this.linkM3u8});

  ServerData.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    slug = json['slug'];
    filename = json['filename'];
    linkEmbed = json['link_embed'];
    linkM3u8 = json['link_m3u8'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['slug'] = this.slug;
    data['filename'] = this.filename;
    data['link_embed'] = this.linkEmbed;
    data['link_m3u8'] = this.linkM3u8;
    return data;
  }
}

class Country {
  String? id;
  String? name;
  String? slug;

  Country({this.id, this.name, this.slug});

  Country.fromJson(Map<String, dynamic> json) {
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

