class EpisodesDetail {
  String? name;
  String? slug;
  String? filename;
  String? linkEmbed;
  String? linkM3u8;

  EpisodesDetail(
      {this.name, this.slug, this.filename, this.linkEmbed, this.linkM3u8});

  EpisodesDetail.fromJson(Map<String, dynamic> json) {
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
