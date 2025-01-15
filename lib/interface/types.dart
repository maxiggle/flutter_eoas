class AuthCredential {
  final String userId;
  final String? accessToken;
  final String? idToken;

  AuthCredential({
    required this.userId,
    this.accessToken,
    this.idToken,
  });
}
