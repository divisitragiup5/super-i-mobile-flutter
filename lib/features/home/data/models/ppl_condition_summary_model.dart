class PplSignatureItem {
  final String status;
  final int count;

  PplSignatureItem({
    required this.status,
    required this.count,
  });

  factory PplSignatureItem.fromJson(Map<String, dynamic> json) {
    int c = 0;
    if (json['_count'] is Map && json['_count']['_all'] != null) {
      c = json['_count']['_all'] is int
          ? json['_count']['_all']
          : int.tryParse('${json['_count']['_all']}') ?? 0;
    } else if (json['count'] != null) {
      c = json['count'] is int ? json['count'] : int.tryParse('${json['count']}') ?? 0;
    }

    return PplSignatureItem(
      status: json['status']?.toString() ?? '',
      count: c,
    );
  }
}

class PplStatusItem {
  final String kategoriObjek;
  final int count;

  PplStatusItem({
    required this.kategoriObjek,
    required this.count,
  });

  factory PplStatusItem.fromJson(Map<String, dynamic> json) {
    int c = 0;
    if (json['_count'] is Map && json['_count']['_all'] != null) {
      c = json['_count']['_all'] is int
          ? json['_count']['_all']
          : int.tryParse('${json['_count']['_all']}') ?? 0;
    } else if (json['count'] != null) {
      c = json['count'] is int ? json['count'] : int.tryParse('${json['count']}') ?? 0;
    }

    return PplStatusItem(
      kategoriObjek: json['kategoriObjek']?.toString() ?? '',
      count: c,
    );
  }
}

class PplConditionSummaryModel {
  final List<PplSignatureItem> signatures;
  final List<PplStatusItem> statuses;

  PplConditionSummaryModel({
    required this.signatures,
    required this.statuses,
  });

  int get total {
    if (signatures.isNotEmpty) {
      return signatures.fold(0, (sum, item) => sum + item.count);
    }
    return statuses.fold(0, (sum, item) => sum + item.count);
  }

  factory PplConditionSummaryModel.fromJson(Map<String, dynamic> json) {
    final sigList = (json['signature'] as List?)
            ?.map((e) => PplSignatureItem.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    final statList = (json['status'] as List?)
            ?.map((e) => PplStatusItem.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    return PplConditionSummaryModel(
      signatures: sigList,
      statuses: statList,
    );
  }
}
