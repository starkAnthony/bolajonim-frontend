import 'meal_model.dart';

class PickupPersonModel {
  final int? personNo;
  final String personName;
  final String relationName;
  final String? phoneNo;
  final String? iconType;
  final bool isDefault;

  const PickupPersonModel({
    this.personNo,
    required this.personName,
    required this.relationName,
    this.phoneNo,
    this.iconType,
    this.isDefault = false,
  });

  factory PickupPersonModel.fromJson(Map<String, dynamic> json) {
    return PickupPersonModel(
      personNo: json['personNo'] is int
          ? json['personNo'] as int
          : int.tryParse(json['personNo']?.toString() ?? ''),
      personName: json['personNm']?.toString() ?? '',
      relationName: json['relationNm']?.toString() ?? '',
      phoneNo: json['phoneNo']?.toString(),
      iconType: json['iconType']?.toString(),
      isDefault: (json['isDefault']?.toString() ?? 'N').toUpperCase() == 'Y',
    );
  }
}

class PickupPlanModel {
  final int? planNo;
  final String pickupDate;
  final String personName;
  final String relationName;
  final String? plannedTime;
  final String status;
  final String? noteText;

  const PickupPlanModel({
    this.planNo,
    required this.pickupDate,
    required this.personName,
    required this.relationName,
    this.plannedTime,
    required this.status,
    this.noteText,
  });

  factory PickupPlanModel.fromJson(Map<String, dynamic> json) {
    return PickupPlanModel(
      planNo: json['planNo'] is int
          ? json['planNo'] as int
          : int.tryParse(json['planNo']?.toString() ?? ''),
      pickupDate: json['pickupDt']?.toString() ?? '',
      personName: json['personNm']?.toString() ?? '',
      relationName: json['relationNm']?.toString() ?? '',
      plannedTime: json['plannedTime']?.toString(),
      status: json['statusCd']?.toString() ?? 'planned',
      noteText: json['noteText']?.toString(),
    );
  }

  DateTime? get parsedDate => BolajonimDateParser.parseYyyyMmDd(pickupDate);
}

class PickupModel {
  final PickupPlanModel? todayPlan;
  final List<PickupPersonModel> persons;
  final List<PickupPlanModel> history;

  const PickupModel({
    this.todayPlan,
    required this.persons,
    required this.history,
  });

  factory PickupModel.fromJson(Map<String, dynamic> json) {
    final rawPersons = json['persons'];
    final persons = rawPersons is List
        ? rawPersons
            .map(
              (item) =>
                  PickupPersonModel.fromJson(item as Map<String, dynamic>),
            )
            .toList()
        : <PickupPersonModel>[];

    final rawHistory = json['history'];
    final history = rawHistory is List
        ? rawHistory
            .map(
              (item) => PickupPlanModel.fromJson(item as Map<String, dynamic>),
            )
            .toList()
        : <PickupPlanModel>[];

    final todayPlanJson = json['todayPlan'];
    final todayPlan = todayPlanJson is Map<String, dynamic>
        ? PickupPlanModel.fromJson(todayPlanJson)
        : null;

    return PickupModel(
      todayPlan: todayPlan,
      persons: persons,
      history: history,
    );
  }
}
