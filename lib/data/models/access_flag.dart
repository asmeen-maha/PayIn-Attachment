/// A `{code, name, chk}` row returned by the permission endpoints.
///
/// * `checkprint` → the logged-in user; `chk == 'Y'` means they may edit/delete.
/// * `checkdept`  → the user's department; `chk == 'finance'` means they may verify.
class AccessFlag {
  const AccessFlag({this.code, this.name, this.chk});

  final String? code;
  final String? name;
  final String? chk;

  factory AccessFlag.fromJson(Map<String, dynamic> json) => AccessFlag(
        code: json['code']?.toString(),
        name: json['name']?.toString(),
        chk: json['chk']?.toString(),
      );
}
