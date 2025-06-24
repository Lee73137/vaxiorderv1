class UserProfile {
  final String id;
  final String rolecode;
  final String usercode;
  final String email;
  final String? phonenumber;
  final String username;
  final String? repcode;
  final String? fullname;

  UserProfile({
    required this.id,
    required this.rolecode,
    required this.usercode,
    required this.email,
    required this.phonenumber,
    required this.username,
    required this.repcode,
    required this.fullname,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final normalizedJson = {
      for (var key in json.keys) key.toLowerCase(): json[key],
    };
    return UserProfile(
      id: normalizedJson['id'],
      rolecode: normalizedJson['rolecode'],
      usercode: normalizedJson['usercode'],
      email: normalizedJson['email'],
      phonenumber: normalizedJson['phonenumber'],
      username: normalizedJson['username'],
      repcode: normalizedJson['repcode'],
      fullname: normalizedJson['fullname'],
    );
  }

  Map<String, dynamic> toMap() => {
    'Id': id,
    'rolecode': rolecode,
    'usercode': usercode,
    'Email': email,
    'PhoneNumber': phonenumber,
    'UserName': username,
    'repcode': repcode,
    'fullname': fullname,
  };
}
