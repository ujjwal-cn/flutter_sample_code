import 'package:go4sheq/util/app_util.dart';

class EmployeeDetails {
  int? id;
  int? roleId;
  String? email;
  int? company;
  String? phone;
  String? firstName;
  String? lastName;

  EmployeeDetails({
    this.id,
    this.roleId,
    this.email,
    this.company,
    this.phone,
    this.firstName,
    this.lastName,
  });

  EmployeeDetails.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    roleId = json['role_id'];
    email = json['email'];
    company = json['company'];
    phone = json['phone'];
    firstName = json['first_name'];
    lastName = json['last_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['role_id'] = roleId;
    data['email'] = email;
    data['company'] = company;
    data['phone'] = phone;
    data['first_name'] = firstName;
    data['last_name'] = lastName;
    return data;
  }

  @override
  toString() {
    String name = '';
    if (firstName != null) name += firstName!;
    if (lastName != null) name += ' $lastName';
    return name;
  }

  @override
  bool operator ==(other) {
    return (other is EmployeeDetails) && other.id == id;
  }

  @override
  int get hashCode => id ?? super.hashCode;

  static findEmployeeUsingId({required List<EmployeeDetails> employees, required int id}) {
    try {
      return employees.firstWhere(
        (element) => element.id == id,
      );
    } catch (e) {
      AppUtil.log(e);
    }
  }
}
