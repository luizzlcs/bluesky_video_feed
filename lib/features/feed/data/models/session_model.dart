class SessionModel {
  final String accessJwt;
  final String refreshJwt;
  final String did;
  final String handle;

  SessionModel({
    required this.accessJwt,
    required this.refreshJwt,
    required this.did,
    required this.handle,
  });

  factory SessionModel.fromJson(Map<String, dynamic> json) {
    return SessionModel(
      accessJwt: json['accessJwt'] ?? '',
      refreshJwt: json['refreshJwt'] ?? '',
      did: json['did'] ?? '',
      handle: json['handle'] ?? '',
    );
  }
}