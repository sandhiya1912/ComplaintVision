// class ComplaintModel {
//   final String id;
//   final String? title;  // Nullable title
//   final String? description;  // Nullable description
//   final String? status;  // Nullable status
//   final DateTime createdAt;

//   ComplaintModel({
//     required this.id,
//     this.title,  // Make it optional (nullable)
//     this.description,  // Make it optional (nullable)
//     this.status,  // Make it optional (nullable)
//     required this.createdAt,
//   });

//   factory ComplaintModel.fromJson(Map<String, dynamic> json) {
//     return ComplaintModel(
//       id: json['id'] ?? '',  // Provide a default value for id
//       title: json['title'],  // Allow nullable fields
//       description: json['description'],  // Allow nullable fields
//       status: json['status'],  // Allow nullable fields
//       createdAt: DateTime.parse(json['createdAt']),
//     );
//   }
// }
class ComplaintModel {
  final String id;
  final String? title;
  final String? description;
  final String? status;
  final List<String>? uploadedFiles;  // Change imageUrl to uploadedFiles as a list
  final DateTime createdAt;

  ComplaintModel({
    required this.id,
    this.title,
    this.description,
    this.status,
    this.uploadedFiles,  // Initialize the uploadedFiles field
    required this.createdAt,
  });

  // Factory method to create an instance from JSON data
  factory ComplaintModel.fromJson(Map<String, dynamic> json) {
    return ComplaintModel(
      id: json['id'] ?? '',
      title: json['title'],
      description: json['description'],
      status: json['status'],
      // Parse uploadedFiles from JSON, if it's present, cast it to List<String>
      uploadedFiles: (json['uploadedFiles'] as List<dynamic>?)?.cast<String>(),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  // Method to convert the object back to JSON format
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status,
      'uploadedFiles': uploadedFiles,  // Convert uploadedFiles to JSON
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
