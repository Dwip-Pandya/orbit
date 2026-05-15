class PasswordEntry {
  final String id;
  final String title;
  final String username;
  final String password;
  final String? website;
  final String? notes;
  final String category;
  final bool isFavorite;
  final DateTime createdAt;

  PasswordEntry({
    required this.id,
    required this.title,
    required this.username,
    required this.password,
    this.website,
    this.notes,
    this.category = 'General',
    this.isFavorite = false,
    required this.createdAt,
  });

  PasswordEntry copyWith({
    String? id,
    String? title,
    String? username,
    String? password,
    String? website,
    String? notes,
    String? category,
    bool? isFavorite,
    DateTime? createdAt,
  }) {
    return PasswordEntry(
      id: id ?? this.id,
      title: title ?? this.title,
      username: username ?? this.username,
      password: password ?? this.password,
      website: website ?? this.website,
      notes: notes ?? this.notes,
      category: category ?? this.category,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
