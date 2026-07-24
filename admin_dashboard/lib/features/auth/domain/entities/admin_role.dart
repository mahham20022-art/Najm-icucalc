/// Mirrors `MED100_ARCHITECTURE.md` §7's Auth custom claim `role`
/// (`learner | editor | admin | institution_admin`) — `none` is this
/// app's own addition for "no role claim at all," not a value Firestore
/// ever stores.
enum AdminRole { learner, editor, admin, institutionAdmin, none }

extension AdminRoleAccess on AdminRole {
  /// Whether this role may use the admin dashboard at all — `editor`
  /// gets in (content-management workflows are editor-scoped per the
  /// architecture doc), `admin` gets everything, everyone else is
  /// turned away at the door.
  bool get canAccessDashboard => this == AdminRole.admin || this == AdminRole.editor;

  static AdminRole fromClaim(String? raw) => switch (raw) {
    'learner' => AdminRole.learner,
    'editor' => AdminRole.editor,
    'admin' => AdminRole.admin,
    'institution_admin' => AdminRole.institutionAdmin,
    _ => AdminRole.none,
  };
}
