class EducationModel {
  final String imageUrl;
  final String title;
  final String description;

  EducationModel({
    required this.imageUrl,
    required this.title,
    required this.description,
  });

  factory EducationModel.fromJson(Map<String, dynamic> json) {
    return EducationModel(
      imageUrl: json['imageUrl'],
      title: json['title'],
      description: json['description'],
    );
  }
}
