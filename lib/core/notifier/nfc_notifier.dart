import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';

class NFCNotifier extends ChangeNotifier {
  bool _isProcessing = false;
  String _message = "";
  String _errorMessage = "";

  bool get isProcessing => _isProcessing;
  String get message => _message;
  String get errorMessage => _errorMessage;
  bool get hasError => _errorMessage.isNotEmpty;

  Future<void> startNFCOperation({
    required NFCOperation nfcOperation,
    String dataType = "",
  }) async {
    try {
      _isProcessing = true;
      _message = "";
      _errorMessage = "";  // Clear previous errors
      notifyListeners();

      bool isAvailable = await NfcManager.instance.isAvailable();

      if (isAvailable) {
        NfcManager.instance.startSession(
          onDiscovered: (NfcTag nfcTag) async {
            if (nfcOperation == NFCOperation.read) {
              await _readFromTag(tag: nfcTag);
            } else if (nfcOperation == NFCOperation.write) {
              await _writeToTag(nfcTag: nfcTag, dataType: dataType);
              _message = "Write Successful";
            }

            _isProcessing = false;
            notifyListeners();
            await NfcManager.instance.stopSession();
          },
          onError: (e) async {
            _isProcessing = false;
            _errorMessage = e.toString();
            notifyListeners();
          },
        );
      } else {
        _isProcessing = false;
        _errorMessage = "Please enable NFC in settings.";
        notifyListeners();
      }
    } catch (e) {
      _isProcessing = false;
      _errorMessage = "Exception: ${e.toString()}";
      notifyListeners();
    }
  }

  Future<void> _readFromTag({required NfcTag tag}) async {
    try {
      Map<String, dynamic> nfcData = {
        'nfca': tag.data['nfca'],
        'mifareultralight': tag.data['mifareultralight'],
        'ndef': tag.data['ndef']
      };

      String? decodedText;
      if (nfcData.containsKey('ndef')) {
        List<int> payload =
            nfcData['ndef']['cachedMessage']?['records']?[0]['payload'];
        decodedText = String.fromCharCodes(payload);
      }

      _message = decodedText ?? "No Data Found";
    } catch (e) {
      _errorMessage = "Read Error: ${e.toString()}";
    }
  }

  Future<void> _writeToTag({
    required NfcTag nfcTag,
    required String dataType,
  }) async {
    try {
      NdefMessage message = _createNdefMessage(dataType: dataType);
      await Ndef.from(nfcTag)?.write(message);
      _message = "Write Successful";
    } catch (e) {
      _errorMessage = "Write Error: ${e.toString()}";
    }
  }

  NdefMessage _createNdefMessage({required String dataType}) {
    switch (dataType) {
      case 'URL':
        return NdefMessage([
          NdefRecord.createUri(Uri.parse("https://www.devadnani.com")),
        ]);
      case 'MAIL':
        String emailData = 'mailto:devadnani26@gmail.com';
        return NdefMessage([
          NdefRecord.createUri(Uri.parse(emailData)),
        ]);
      case 'CONTACT':
        String contactData =
            'BEGIN:VCARD\nVERSION:2.1\nN:John Doe\nTEL:+1234567890\nEMAIL:devadnani26@gmail.com\nEND:VCARD';
        Uint8List contactBytes = utf8.encode(contactData);
        return NdefMessage([
          NdefRecord.createMime('text/vcard', contactBytes),
        ]);
      default:
        return const NdefMessage([]);
    }
  }
}

enum NFCOperation { read, write }
