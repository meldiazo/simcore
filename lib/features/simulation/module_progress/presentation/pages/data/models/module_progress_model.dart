class ModuleProgressModel {
  final String module;
  final String status;

  ModuleProgressModel({
    required this.module,
    required this.status,
  });

  factory ModuleProgressModel.fromJson(Map<String, dynamic> json) {
    return ModuleProgressModel(
      module: json['module'] ?? '',
      status: json['status'] ?? '',
    );
  }
}