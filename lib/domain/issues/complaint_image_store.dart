import 'dart:typed_data';

abstract interface class ComplaintImageStore {
  List<String> get demoImageRefs;

  String labelFor(String imageRef);

  Future<Uint8List> load(String imageRef);
}
