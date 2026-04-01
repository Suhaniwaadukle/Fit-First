class RegisterRequest {
  final String name;
  final String email;
  final String phonecode;
  final String mobile;
  final String password;
  final String referralCode;

  RegisterRequest({
    required this.name,
    required this.email,
    required this.phonecode,
    required this.mobile,
    required this.password,
    required this.referralCode,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'phonecode': phonecode,
        'mobile': mobile,
        'password': password,
        'referral_code': referralCode,
      };
}
