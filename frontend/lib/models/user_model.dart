// lib/models/user_model.dart
class UserModel {
  final String uid;
  final String? name;
  final String? email;
  final String? phone;
  final double balance;

  UserModel({
    required this.uid,
    this.name,
    this.email,
    this.phone,
    this.balance = 0.0,
  });

  factory UserModel.fromMap(String uid, Map<String, dynamic>? map) {
    if (map == null) {
      return UserModel(uid: uid);
    }
    final balRaw = map['balance'];
    double bal = 0.0;
    if (balRaw is num) bal = balRaw.toDouble();
    else if (balRaw is String) bal = double.tryParse(balRaw) ?? 0.0;
    return UserModel(
      uid: uid,
      name: map['name'],
      email: map['email'],
      phone: map['phone']?.toString(),
      balance: bal,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'balance': balance,
    };
  }
}
