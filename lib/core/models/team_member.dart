class TeamMember {
  final String name;
  final String role;
  final String? avatar;

  const TeamMember({
    required this.name,
    required this.role,
    this.avatar,
  });
}
