/// Backend endpoints used by the app.
class ApiConfig {
  ApiConfig._();

  /// Single PHP endpoint; the action is selected with the `param` field.
  static const String endpoint = 'http://172.2.100.14/clientele_cm/marketing.php';

  /// Staff photos, looked up by employee code: `<base>/<code>.jpg`.
  static const String staffPhotoBaseUrl = 'http://172.2.200.50/personpic';

  static String staffPhotoUrl(String code) => '$staffPhotoBaseUrl/$code.jpg';
}
