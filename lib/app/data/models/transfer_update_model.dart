enum TransferStatus {
  receiving,
  sending,
  success, // Transfer is complete
  failed,
  canceled,
  saved, // Saved file to local storage
}

class TransferUpdate {
  final int payloadId;
  final String fileName;
  final int fileSize;
  final double progress;
  final TransferStatus status;
  final String? tempFilePath; // Path where file transfer ends
  final String? finalFilePath; // Path where file is stored
  final bool isSender;

  TransferUpdate({
    required this.payloadId,
    required this.fileName,
    required this.fileSize,
    required this.isSender,
    this.progress = 0.0,
    this.status = TransferStatus.receiving,
    this.tempFilePath,
    this.finalFilePath,
  });

  TransferUpdate copyWith({
    double? progress,
    TransferStatus? status,
    String? tempFilePath,
    String? finalFilePath,
  }) {
    return TransferUpdate(
      payloadId: payloadId,
      fileName: fileName,
      fileSize: fileSize,
      progress: progress ?? this.progress,
      status: status ?? this.status,
      isSender: isSender,
      tempFilePath: tempFilePath ?? this.tempFilePath,
      finalFilePath: finalFilePath ?? this.finalFilePath,
    );
  }
}