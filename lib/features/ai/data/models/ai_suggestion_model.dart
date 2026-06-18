class AiSuggestionModel {
  const AiSuggestionModel({
    required this.type,
    required this.content,
    required this.aiGenerated,
  });

  final String type;
  final String content;
  final bool aiGenerated;

  factory AiSuggestionModel.fromJson(Map<String, dynamic> json) {
    return AiSuggestionModel(
      type: json['type']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      aiGenerated: json['aiGenerated'] == true,
    );
  }
}
