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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'username': username,
      'password': password,
      'website': website,
      'notes': notes,
      'category': category,
      'isFavorite': isFavorite,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory PasswordEntry.fromJson(Map<String, dynamic> json) {
    return PasswordEntry(
      id: json['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: json['title'] as String? ?? 'Untitled',
      username: json['username'] as String? ?? '',
      password: json['password'] as String? ?? '',
      website: json['website'] as String?,
      notes: json['notes'] as String?,
      category: json['category'] as String? ?? 'General',
      isFavorite: json['isFavorite'] as bool? ?? false,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : DateTime.now(),
    );
  }
}

