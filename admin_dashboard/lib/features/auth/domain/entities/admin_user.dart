import 'package:equatable/equatable.dart';

import 'admin_role.dart';

class AdminUser extends Equatable {
  const AdminUser({required this.uid, required this.email, required this.role});

  final String uid;
  final String? email;
  final AdminRole role;

  @override
  List<Object?> get props => [uid, email, role];
}
