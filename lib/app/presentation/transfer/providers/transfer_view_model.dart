import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:nearby_connections/nearby_connections.dart';
import 'package:path_provider/path_provider.dart';
import 'package:peerlink/app/data/models/transfer_update_model.dart';
import 'package:peerlink/app/data/services/p2p_service.dart';
import 'package:peerlink/app/data/services/library_service.dart';
import 'package:peerlink/app/data/models/saved_file_model.dart';
import 'package:uuid/uuid.dart';

class TransferViewModel extends ChangeNotifier {
  final P2pService _p2pService;
  final LibraryService _libraryService;
  final String _peerId;
  final String _peerName;
  StreamSubscription? _payloadSubscription;
  StreamSubscription? _payloadTransferSubscription;
  final Uuid _uuid = Uuid();

  final Map<int, String> _pendingFilenames = {};

  final Map<int, TransferUpdate> _transfers = {};
  List<TransferUpdate> get transfers => _transfers.values.toList();

  TransferViewModel(
    this._p2pService,
    this._libraryService,
    this._peerId,
    this._peerName,
  ) {
    _payloadSubscription = _p2pService.payloadStream.listen((event) {
      if (event['id'] == _peerId) {
        _handleIncomingPayload(event['payload']);
      }
    });

    _payloadTransferSubscription = _p2pService.payloadTransferStream.listen((
      event,
    ) {
      if (event['id'] == _peerId) {
        _handleTransferUpdate(event['update']);
      }
    });
  }

  void _handleIncomingPayload(Payload payload) {
    final fileName =
        _pendingFilenames.remove(payload.id) ?? "Receiving file...";

    if (payload.type == PayloadType.FILE) {
      _transfers[payload.id] = TransferUpdate(
        payloadId: payload.id,
        fileName: fileName,
        fileSize: 0,
        status: TransferStatus.receiving,
        tempFilePath: payload.uri,
        isSender: false,
      );
      notifyListeners();
    } else if (payload.type == PayloadType.BYTES) {
      final data = jsonDecode(String.fromCharCodes(payload.bytes!));
      if (data['type'] == 'filename') {
        final payloadId = data['payloadId'];
        final fileName = data['fileName'];

        if (_transfers.containsKey(payloadId)) {
          final transfer = _transfers[payloadId]!;
          _transfers[payloadId] = TransferUpdate(
            payloadId: payloadId,
            fileName: fileName,
            fileSize: transfer.fileSize,
            status: transfer.status,
            tempFilePath: transfer.tempFilePath,
            isSender: transfer.isSender,
          );
        } else {
          _pendingFilenames[payloadId] = fileName;
        }
        notifyListeners();
      }
    }
  }

  void _handleTransferUpdate(PayloadTransferUpdate update) {
    if (_transfers.containsKey(update.id)) {
      final current = _transfers[update.id]!;
      final fileSize = (current.fileSize == 0)
          ? update.totalBytes
          : current.fileSize;

      TransferStatus status = current.status;
      if (update.status == PayloadStatus.SUCCESS) {
        status = TransferStatus.success;
      } else if (update.status == PayloadStatus.FAILURE) {
        status = TransferStatus.failed;
      } else if (update.status == PayloadStatus.CANCELED) {
        status = TransferStatus.canceled;
      }

      _transfers[update.id] = TransferUpdate(
        payloadId: update.id,
        fileName: current.fileName,
        fileSize: fileSize,
        progress: update.bytesTransferred / (fileSize == 0 ? 1 : fileSize),
        status: status,
        tempFilePath: current.tempFilePath,
        isSender: current.isSender,
      );
      notifyListeners();
    }
  }

  Future<void> sendFile(String filePath) async {
    final file = File(filePath);
    final fileName = file.path.split('/').last;
    final fileSize = await file.length();

    final payloadId = await _p2pService.sendFile(_peerId, filePath);

    await _p2pService.sendBytes(_peerId, {
      'type': 'filename',
      'payloadId': payloadId,
      'fileName': fileName,
    });

    _transfers[payloadId] = TransferUpdate(
      payloadId: payloadId,
      fileName: fileName,
      fileSize: fileSize,
      status: TransferStatus.sending,
      isSender: true,
    );
    notifyListeners();
  }

  Future<void> saveFile(int payloadId) async {
    final transfer = _transfers[payloadId];
    if (transfer == null || transfer.tempFilePath == null) return;

    final directory = await getExternalStorageDirectory();
    if (directory == null) return;

    final downloadsDir = Directory('${directory.path}/PeerLink');
    if (!await downloadsDir.exists()) {
      await downloadsDir.create(recursive: true);
    }

    final newPath = '${downloadsDir.path}/${transfer.fileName}';
    final uriString = transfer.tempFilePath!;

    try {
      bool success = await Nearby().copyFileAndDeleteOriginal(
        uriString,
        newPath,
      );

      if (success) {
        final savedFileRecord = SavedFile(
          id: _uuid.v4(), 
          fileName: transfer.fileName,
          filePath: newPath,
          fileSize: transfer.fileSize,
          dateSaved: DateTime.now(), 
          senderName: _peerName, 
        );

        await _libraryService.addFile(savedFileRecord);

        _transfers[payloadId] = transfer.copyWith(
          status: TransferStatus.saved,
          finalFilePath: newPath,
        );
      } else {
        throw Exception("Failed to copy file from URI.");
      }
    } catch (e) {
      print("Error saving file: $e");
      _transfers[payloadId] = transfer.copyWith(status: TransferStatus.failed);
    } finally {
      notifyListeners();
    }
  }

  void cancelTransfer(int payloadId) {
    _p2pService.cancelTransfer(payloadId);
  }

  @override
  void dispose() {
    _payloadSubscription?.cancel();
    _payloadTransferSubscription?.cancel();
    super.dispose();
  }
}
