abstract interface class ComplaintPhotoCapture {
  Future<String?> takePhoto();

  Future<String?> pickFromGallery();
}
