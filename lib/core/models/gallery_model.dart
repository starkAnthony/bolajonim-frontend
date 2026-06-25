class GalleryPhotoModel {
  final int? photoNo;
  final String imageUrl;
  final String caption;

  const GalleryPhotoModel({
    this.photoNo,
    required this.imageUrl,
    required this.caption,
  });

  factory GalleryPhotoModel.fromJson(Map<String, dynamic> json) {
    return GalleryPhotoModel(
      photoNo: json['photoNo'] is int
          ? json['photoNo'] as int
          : int.tryParse(json['photoNo']?.toString() ?? ''),
      imageUrl: json['imageUrl']?.toString() ?? '',
      caption: json['caption']?.toString() ?? '',
    );
  }
}

class GalleryAlbumModel {
  final int? albumNo;
  final String albumTitle;
  final String albumSubtitle;
  final String coverUrl;
  final List<GalleryPhotoModel> photos;

  const GalleryAlbumModel({
    this.albumNo,
    required this.albumTitle,
    required this.albumSubtitle,
    required this.coverUrl,
    required this.photos,
  });

  factory GalleryAlbumModel.fromJson(Map<String, dynamic> json) {
    final rawPhotos = json['photos'];
    final photos = rawPhotos is List
        ? rawPhotos
            .map(
              (item) => GalleryPhotoModel.fromJson(item as Map<String, dynamic>),
            )
            .toList()
        : <GalleryPhotoModel>[];

    return GalleryAlbumModel(
      albumNo: json['albumNo'] is int
          ? json['albumNo'] as int
          : int.tryParse(json['albumNo']?.toString() ?? ''),
      albumTitle: json['albumTitle']?.toString() ?? '',
      albumSubtitle: json['albumSubtitle']?.toString() ?? '',
      coverUrl: json['coverUrl']?.toString() ?? '',
      photos: photos,
    );
  }
}

class GalleryDayModel {
  final String galleryDate;
  final String teacherNote;
  final List<GalleryAlbumModel> albums;

  const GalleryDayModel({
    required this.galleryDate,
    required this.teacherNote,
    required this.albums,
  });

  factory GalleryDayModel.fromJson(Map<String, dynamic> json) {
    final rawAlbums = json['albums'];
    final albums = rawAlbums is List
        ? rawAlbums
            .map(
              (item) => GalleryAlbumModel.fromJson(item as Map<String, dynamic>),
            )
            .toList()
        : <GalleryAlbumModel>[];

    return GalleryDayModel(
      galleryDate: json['galleryDt']?.toString() ?? '',
      teacherNote: json['teacherNote']?.toString() ?? '',
      albums: albums,
    );
  }
}
