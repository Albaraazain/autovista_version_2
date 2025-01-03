class Document {
  final String? id;
  final String category;
  final String? description;
  final Map<String, dynamic> fileData;
  final String userId;

  Document({
    this.id,
    required this.category,
    this.description,
    required this.fileData,
    required this.userId,
  });

  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      id: json['id'] as String?,
      category: json['category'] as String,
      description: json['description'] as String?,
      fileData: Map<String, dynamic>.from(json['file_data']),
      userId: json['user_id'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'description': description,
      'file_data': fileData,
      'user_id': userId,
    };
  }
}
