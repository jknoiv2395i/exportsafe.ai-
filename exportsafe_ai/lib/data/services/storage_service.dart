import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String?> uploadFile(PlatformFile file, String path) async {
    try {
      final ref = _storage.ref().child(path);
      UploadTask? uploadTask;

      if (kIsWeb) {
        if (file.bytes != null) {
          uploadTask = ref.putData(file.bytes!);
        } else {
          return null; 
        }
      } else {
        if (file.path != null) {
          final ioFile = File(file.path!);
          uploadTask = ref.putFile(ioFile);
        } else {
          return null;
        }
      }

      final snapshot = await uploadTask.whenComplete(() {});
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      if (kDebugMode) {
        print('Error uploading file: $e');
      }
      return null;
    }
  }
}
