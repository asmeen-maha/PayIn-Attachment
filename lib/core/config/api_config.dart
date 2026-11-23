/// Backend endpoints used by the app (internal network only).
class ApiConfig {
  ApiConfig._();

  /// Single PHP endpoint; the action is selected with the `param` field.
  static const String endpoint = 'http://172.2.100.14/clientele_cm/marketing.php';

  /// Staff photos, looked up by employee code: `<base>/<code>.jpg`.
  static const String staffPhotoBaseUrl = 'http://172.2.200.50/personpic';

  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration sendTimeout = Duration(seconds: 20);
  static const Duration receiveTimeout = Duration(seconds: 30);

  /// How long the "all PA" search index is reused before it is fetched again.
  static const Duration searchIndexTtl = Duration(minutes: 5);

  static String? staffPhotoUrl(String? code) =>
      (code == null || code.trim().isEmpty) ? null : '$staffPhotoBaseUrl/${Uri.encodeComponent(code.trim())}.jpg';
}
