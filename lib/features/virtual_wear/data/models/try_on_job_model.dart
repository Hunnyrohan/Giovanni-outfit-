import '../../domain/entities/try_on_job_entity.dart';

class TryOnJobModel extends TryOnJobEntity {
  const TryOnJobModel({
    required super.id,
    required super.status,
    required super.createdAt,
    required super.updatedAt,
    super.wardrobeItemId,
    super.resultImageUrl,
    super.processingTime,
    super.errorMessage,
  });

  factory TryOnJobModel.fromJson(Map<String, dynamic> json) {
    return TryOnJobModel(
      id: json['id'] as String,
      wardrobeItemId: json['wardrobeItemId'] as String?,
      status: tryOnStatusFromString(json['status'] as String),
      resultImageUrl: json['resultImageUrl'] as String?,
      processingTime: (json['processingTime'] as num?)?.toDouble(),
      errorMessage: json['errorMessage'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
