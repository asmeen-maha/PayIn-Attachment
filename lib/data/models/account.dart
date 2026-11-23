/// An accounting code the user can assign to a PA line.
class Account {
  const Account({required this.code, required this.name});

  final String code;
  final String name;

  factory Account.fromJson(Map<String, dynamic> json) => Account(
        code: json['acccode']?.toString() ?? '',
        name: json['accname']?.toString() ?? '',
      );
}
