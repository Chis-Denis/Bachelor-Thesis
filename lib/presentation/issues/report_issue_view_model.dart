import '../../application/issues/report_issue.dart';
import '../../domain/issues/complaint_photo_capture.dart';
import '../common/view_model.dart';

class ReportIssueViewModel extends ViewModel {
  final ReportIssue _report;
  final ComplaintPhotoCapture _photoCapture;

  bool isSubmitting = false;
  bool isCapturing = false;
  String? errorMessage;

  ReportIssueViewModel(this._report, this._photoCapture);

  Future<String?> takePhoto() => _capture(_photoCapture.takePhoto);

  Future<String?> pickFromGallery() => _capture(_photoCapture.pickFromGallery);

  Future<String?> _capture(Future<String?> Function() action) async {
    isCapturing = true;
    errorMessage = null;
    notify();
    String? ref;
    try {
      ref = await action();
    } catch (_) {
      errorMessage = 'Could not access the camera or gallery';
    }
    isCapturing = false;
    notify();
    return ref;
  }

  Future<bool> submit({
    required int restaurantId,
    int? orderId,
    required String description,
    required String imageRef,
  }) async {
    isSubmitting = true;
    errorMessage = null;
    notify();
    final result = await _report(
      restaurantId: restaurantId,
      orderId: orderId,
      description: description,
      imageRef: imageRef,
    );
    isSubmitting = false;
    if (!result.isSuccess) errorMessage = result.error;
    notify();
    return result.isSuccess;
  }

  void clearError() => errorMessage = null;
}
