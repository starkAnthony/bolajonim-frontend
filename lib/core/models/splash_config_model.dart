class SplashConfigModel {

  final int? splashNo;

  final String? kgNo;

  final String? imageUrl;

  final String? caption;

  final String? validFrom;

  final String? validTo;



  const SplashConfigModel({

    this.splashNo,

    this.kgNo,

    this.imageUrl,

    this.caption,

    this.validFrom,

    this.validTo,

  });



  bool get hasImage => (imageUrl ?? '').trim().isNotEmpty;



  factory SplashConfigModel.fromJson(Map<String, dynamic>? json) {

    if (json == null) return const SplashConfigModel();

    return SplashConfigModel(

      splashNo: int.tryParse(json['splashNo']?.toString() ?? ''),

      kgNo: json['kgNo']?.toString(),

      imageUrl: json['imageUrl']?.toString(),

      caption: json['caption']?.toString(),

      validFrom: json['validFrom']?.toString(),

      validTo: json['validTo']?.toString(),

    );

  }

}


