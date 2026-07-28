enum TryOnStatus { pending, processing, completed, failed }

TryOnStatus tryOnStatusFromString(String value) {
  switch (value.toUpperCase()) {
    case 'PENDING':
      return TryOnStatus.pending;
    case 'PROCESSING':
      return TryOnStatus.processing;
    case 'COMPLETED':
      return TryOnStatus.completed;
    case 'FAILED':
      return TryOnStatus.failed;
    default:
      return TryOnStatus.failed;
  }
}

class TryOnJobEntity {
  final String id;
  final String? wardrobeItemId;
  final TryOnStatus status;
  final String? resultImageUrl;
  final double? processingTime;
  final String? errorMessage;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TryOnJobEntity({
    required this.id,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.wardrobeItemId,
    this.resultImageUrl,
    this.processingTime,
    this.errorMessage,
  });

  bool get isTerminal => status == TryOnStatus.completed || status == TryOnStatus.failed;
}
