class Exercise {
  final String id;
  final String title;
  final String? description;
  final String? category;
  final String? videoUrl;
  final String? createdAt;
  final String? updatedAt;

  Exercise({
    required this.id,
    required this.title,
    this.description,
    this.category,
    this.videoUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      category: json['category'] as String?,
      videoUrl: json['video_url'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'category': category,
        'video_url': videoUrl,
      };
}
