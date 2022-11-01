import 'dart:convert';
import 'dart:io';
import 'package:go4sheq/model/checklist_audit_type.dart';
import 'package:go4sheq/model/checklist_category.dart';
import 'package:go4sheq/model/checklist_details.dart';
import 'package:go4sheq/model/checklist_report.dart';
import 'package:go4sheq/model/checklist_standard.dart';
import 'package:go4sheq/model/checklist_template_details.dart';
import 'package:go4sheq/model/city_details.dart';
import 'package:go4sheq/model/country_details.dart';
import 'package:go4sheq/model/employee_details.dart';
import 'package:go4sheq/model/notification_details.dart';
import 'package:go4sheq/model/state_details.dart';
import 'package:go4sheq/model/task_details.dart';
import 'package:go4sheq/model/checklist_template.dart';
import 'package:go4sheq/model/user_login_details.dart';
import 'package:go4sheq/network/api_base_helper.dart';
import 'package:go4sheq/util/app_constant.dart';
import 'package:path/path.dart';
import 'package:http/http.dart' as http;

class AppRepository {
  final ApiBaseHelper _apiBaseHelper = ApiBaseHelper();

  /************************************* LOGIN *************************************/

  /// User Login
  Future<UserLoginDetails> userLogin({required String email, required String password}) async {
    String endpoint = "api/user/login";
    Map<String, String> headers = {"Content-Type": "application/json"};
    Map<String, dynamic> body = {"email": email, "password": password};

    final dynamic response = await _apiBaseHelper.post(endpoint, headers: headers, body: jsonEncode(body));

    UserLoginDetails userLoginDetails = UserLoginDetails.fromJson(response);
    return userLoginDetails;
  }

  /// User Forget Password
  Future<String> userForgetPassword({required String email}) async {
    String endpoint = "api/user/forgetPassword";
    Map<String, String> headers = {"Content-Type": "application/json"};
    Map<String, dynamic> body = {"email": email};

    final dynamic response = await _apiBaseHelper.post(endpoint, headers: headers, body: jsonEncode(body));

    return response['message'];
  }

  /// User Reset Password
  Future<String> userResetPassword({required String email, required String password, required String confirmPassword}) async {
    String endpoint = "api/user/resetPassword";
    Map<String, String> headers = {"Content-Type": "application/json"};
    Map<String, dynamic> body = {"email": email, "password": password, "confirmPassword": confirmPassword};

    final dynamic response = await _apiBaseHelper.post(endpoint, headers: headers, body: jsonEncode(body));

    return response['message'];
  }

  /************************************* MY PROFILE *************************************/

  /// Fetch User Details
  Future<User> fetchUserDetails({required int userId}) async {
    String endpoint = "api/user/userDetails/$userId";
    Map<String, String> headers = {"Content-Type": "application/json"};

    final dynamic response = await _apiBaseHelper.get(endpoint, headers: headers);

    return User.fromJson(response['user']);
  }

  /// Update User Details
  Future<String> updateUserDetails({required int userId, File? image, String? firstName, String? lastName, String? phoneNo, String? city, String? state, String? country}) async {
    String endpoint = "api/user/updateUserProfile";
    var request = http.MultipartRequest('POST', Uri.parse(kBaseUrl + endpoint));
    request.headers.addAll({"Content-Type": "multipart/form-data"});

    // Adding text fields
    request.fields['userId'] = "$userId";
    request.fields['first_name'] = "$firstName";
    request.fields['last_name'] = "$lastName";
    request.fields['phone'] = "$phoneNo";
    // request.fields['city'] = (city != null) ? city : '';
    // request.fields['state'] = (state != null) ? state : '';
    // request.fields['country'] = (country != null) ? country : '';

    // Adding files
    if (image != null) {
      var stream = http.ByteStream(image.openRead());
      stream.cast();
      var length = await image.length();
      var multiPort = http.MultipartFile('image', stream, length, filename: basename(image.path));
      request.files.add(multiPort);
    }

    final dynamic response = await _apiBaseHelper.sendMultipartRequest(multipartRequest: request);

    return response['message'];
  }

  /// Change User Password
  Future<String> changeUserPassword({required int userId, required String password, required String newPassword, required String confirmPassword}) async {
    String endpoint = "api/user/changePassword";
    Map<String, String> headers = {"Content-Type": "application/json"};
    Map<String, dynamic> body = {"userId": userId, "password": password, "newPassword": newPassword, "confirmPassword": confirmPassword};

    final dynamic response = await _apiBaseHelper.post(endpoint, headers: headers, body: jsonEncode(body));

    return response['message'];
  }

  /// Fetch Country List
  Future<List<CountryDetails>> fetchCountryList() async {
    String endpoint = "api/user/listCountry";
    Map<String, String> headers = {"Content-Type": "application/json"};

    final dynamic response = await _apiBaseHelper.get(endpoint, headers: headers);

    List<CountryDetails> countryList = [];
    if (response['country'] != null) {
      response['country'].forEach((v) {
        countryList.add(CountryDetails.fromJson(v));
      });
    }
    return countryList;
  }

  /************************************* TASK *************************************/

  /// Fetch Employee List
  Future<List<EmployeeDetails>> fetchEmployeeList({required int companyId, required String searchKey}) async {
    String endpoint = "api/user/listCompanyEmployees/$companyId";
    Map<String, String> headers = {"Content-Type": "application/json"};
    Map<String, dynamic> body = {"searchKey": searchKey};

    final dynamic response = await _apiBaseHelper.post(endpoint, headers: headers, body: jsonEncode(body));

    List<EmployeeDetails> employeeList = [];
    if (response['user'] != null) {
      response['user'].forEach((v) {
        employeeList.add(EmployeeDetails.fromJson(v));
      });
    }
    return employeeList;
  }

  /// Task Create
  Future<String> taskCreate({required TaskDetails taskDetails}) async {
    String endpoint = "api/tasks/save";
    var request = http.MultipartRequest('POST', Uri.parse(kBaseUrl + endpoint));
    request.headers.addAll({"Content-Type": "multipart/form-data"});

    // Adding text fields
    Map<String, String> body = taskDetails.toJsonForTaskCreate();
    request.fields.addAll(body);

    // Adding files
    List<String>? filePath = taskDetails.filePath;
    if (filePath != null) {
      for (int i = 0; i < filePath.length; i++) {
        File imageFile = File(filePath[i]);
        var stream = http.ByteStream(imageFile.openRead());
        stream.cast();
        var length = await imageFile.length();
        var multiPort = http.MultipartFile('file', stream, length, filename: basename(imageFile.path));
        request.files.add(multiPort);
      }
    }

    final dynamic response = await _apiBaseHelper.sendMultipartRequest(multipartRequest: request);

    return response['message'];
  }

  /// Task Update
  Future<String> taskUpdate({required TaskDetails taskDetails}) async {
    String endpoint = "api/tasks/edit";
    var request = http.MultipartRequest('POST', Uri.parse(kBaseUrl + endpoint));
    request.headers.addAll({"Content-Type": "multipart/form-data"});

    // Adding text fields
    Map<String, String> body = taskDetails.toJsonForTaskUpdate();
    request.fields.addAll(body);

    // Adding files
    List<String>? filePath = taskDetails.filePath;
    if (filePath != null) {
      for (int i = 0; i < filePath.length; i++) {
        File imageFile = File(filePath[i]);
        var stream = http.ByteStream(imageFile.openRead());
        stream.cast();
        var length = await imageFile.length();
        var multiPort = http.MultipartFile('file', stream, length, filename: basename(imageFile.path));
        request.files.add(multiPort);
      }
    }

    final dynamic response = await _apiBaseHelper.sendMultipartRequest(multipartRequest: request);

    return response['message'];
  }

  /// Fetch Task List
  Future<List<TaskDetails>> fetchTaskList({required User user}) async {
    String endpoint = "api/tasks/getAllTasksAssignedTo/${user.id}";
    Map<String, String> headers = {"Content-Type": "application/json"};

    final dynamic response = await _apiBaseHelper.get(endpoint, headers: headers);

    List<TaskDetails> taskList = [];
    if (response['data'] != null) {
      response['data'].forEach((v) {
        final taskDetails = TaskDetails.fromJson(v);
        taskDetails.assignedTo = EmployeeDetails(id: user.id, firstName: user.firstName, lastName: user.lastName);
        taskList.add(taskDetails);
      });
    }
    return taskList;
  }

  /************************************* NOTIFICATION *************************************/

  /// Fetch Notification List
  Future<List<NotificationDetails>> fetchNotificationList({required User user}) async {
    String endpoint = "api/notifications/getAllNotifications/${user.id}";
    Map<String, String> headers = {"Content-Type": "application/json"};

    final dynamic response = await _apiBaseHelper.get(endpoint, headers: headers);

    List<NotificationDetails> notificationList = [];
    if (response['data'] != null) {
      response['data'].forEach((v) {
        notificationList.add(NotificationDetails.fromJson(v));
      });
    }
    return notificationList;
  }

  /// Update Notification
  Future<NotificationDetails> updateNotification({required int notificationId, bool? isRead, bool? isArchived}) async {
    String endpoint = "api/notifications/updateNotification/$notificationId";
    Map<String, String> headers = {"Content-Type": "application/json"};
    Map<String, dynamic> body = {};
    if (isRead != null) body['isRead'] = isRead;
    if (isArchived != null) body['isArchived'] = isArchived;

    final dynamic response = await _apiBaseHelper.post(endpoint, headers: headers, body: jsonEncode(body));

    return NotificationDetails.fromJson(response['data']);
  }
}
