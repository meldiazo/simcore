class GroupDashboardItem {
  const GroupDashboardItem({
    required this.groupId,
    required this.groupName,
    this.companyId,
    this.companyName,
    this.companyStatus,
    required this.completedModules,
    required this.moduleProgress,
    required this.incoherences,
  });

  final int groupId;
  final String groupName;
  final int? companyId;
  final String? companyName;
  final String? companyStatus;
  final int completedModules;
  final List<Map<String, dynamic>> moduleProgress;
  final Map<String, dynamic> incoherences;

  factory GroupDashboardItem.fromJson(Map<String, dynamic> json) {
    final rawProgress = json['moduleProgress'] as List<dynamic>? ?? [];
    final progress = rawProgress
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
    final rawIncoherences = json['incoherences'];
    final incoherences = rawIncoherences is Map
        ? Map<String, dynamic>.from(rawIncoherences)
        : <String, dynamic>{};
    return GroupDashboardItem(
      groupId: _parseInt(json, 'groupId'),
      groupName: json['groupName']?.toString() ?? '',
      companyId: json['companyId'] is int ? json['companyId'] as int : null,
      companyName: json['companyName'] as String?,
      companyStatus: json['companyStatus'] as String?,
      completedModules: _parseInt(json, 'completedModules'),
      moduleProgress: progress,
      incoherences: incoherences,
    );
  }

  static int _parseInt(Map<String, dynamic> json, String key) {
    final v = json[key];
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }
}

class TeacherDashboard {
  const TeacherDashboard({
    required this.courseId,
    required this.totalGroups,
    required this.activeCompanies,
    required this.groups,
  });

  final int courseId;
  final int totalGroups;
  final int activeCompanies;
  final List<GroupDashboardItem> groups;

  factory TeacherDashboard.fromJson(Map<String, dynamic> json) {
    final rawGroups = json['groups'] as List<dynamic>? ?? [];
    final groups = rawGroups
        .whereType<Map>()
        .map((e) => GroupDashboardItem.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    return TeacherDashboard(
      courseId: _parseInt(json, 'courseId'),
      totalGroups: _parseInt(json, 'totalGroups'),
      activeCompanies: _parseInt(json, 'activeCompanies'),
      groups: groups,
    );
  }

  static int _parseInt(Map<String, dynamic> json, String key) {
    final v = json[key];
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }
}
