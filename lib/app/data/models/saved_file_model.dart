class SavedFile {
  final String id;
  final String fileName;
  final String filePath;
  final int fileSize;
  final DateTime dateSaved;
  final String senderName;

  SavedFile({
    required this.id,
    required this.fileName,
    required this.filePath,
    required this.fileSize,
    required this.dateSaved,
    required this.senderName,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fileName': fileName,
      'filePath': filePath,
      'fileSize': fileSize,
      'dateSaved': dateSaved.toIso8601String(), 
      'senderName': senderName,
    };
  }

  factory SavedFile.fromJson(Map<String, dynamic> json) {
    return SavedFile(
      id: json['id'],
      fileName: json['fileName'],
      filePath: json['filePath'],
      fileSize: json['fileSize'],
      dateSaved: DateTime.parse(json['dateSaved']),
      senderName: json['senderName'],
    );
  }
}
