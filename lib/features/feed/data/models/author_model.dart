class AuthorModel {
  final String did;
  final String handle;
  final String displayName;
  final String? avatarUrl;

  AuthorModel({
    required this.did,
    required this.handle,
    required this.displayName,
    this.avatarUrl,
  });

  factory AuthorModel.fromJson(Map<String, dynamic> json) {
    return AuthorModel(
      did: json['did'] ?? '',
      handle: json['handle'] ?? '',
      displayName: json['displayName'] ?? json['handle'] ?? 'Usuário',
      avatarUrl: json['avatar'],
    );
  }
}