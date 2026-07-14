import 'dart:io';
import 'dart:math';

import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../domain/issues/complaint_image_ref.dart';
import '../../domain/issues/complaint_photo_capture.dart';

class ImagePickerPhotoCapture implements ComplaintPhotoCapture {
  final ImagePicker _picker;

  ImagePickerPhotoCapture([ImagePicker? picker])
      : _picker = picker ?? ImagePicker();

  static const String _folder = 'complaints';

  @override
  Future<String?> takePhoto() => _pickAndPersist(ImageSource.camera);

  @override
  Future<String?> pickFromGallery() => _pickAndPersist(ImageSource.gallery);

  Future<String?> _pickAndPersist(ImageSource source) async {
    final picked = await _picker.pickImage(source: source, imageQuality: 90);
    if (picked == null) return null;
    return _persist(picked);
  }

  Future<String> _persist(XFile picked) async {
    final documents = await getApplicationDocumentsDirectory();
    final directory = Directory(p.join(documents.path, _folder));
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    final extension = p.extension(picked.path);
    final suffix = Random().nextInt(0x7fffffff).toRadixString(16);
    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}_$suffix$extension';
    final destination = p.join(directory.path, fileName);

    await File(picked.path).copy(destination);
    return ComplaintImageRef.forFile(destination);
  }
}
