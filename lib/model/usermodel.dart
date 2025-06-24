class User {
  final String Id;
  final String UserName;
  final String? rolecode;
  final String? userpass;
  final String? repcode;
  User({
    required this.Id,
    required this.UserName,
    required this.repcode,
    required this.rolecode,
    required this.userpass,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      Id: json['Id'],
      UserName: json['UserName'],
      rolecode: json['rolecode'],
      repcode: json['repcode'],
      userpass: json['userpass'],
    );
  }
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      Id: map['Id'],
      UserName: map['UserName'],
      rolecode: map['rolecode'],
      repcode: map['repcode'],
      userpass: map['userpass'],
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'Id': Id,
      'UserName': UserName,
      'rolecode': rolecode,
      'repcode': repcode,
      'userpass': userpass,
    };
  }
}
