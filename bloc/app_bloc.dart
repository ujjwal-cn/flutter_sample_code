import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:go4sheq/model/checklist_audit_type.dart';
import 'package:go4sheq/model/checklist_category.dart';
import 'package:go4sheq/model/checklist_details.dart';
import 'package:go4sheq/model/checklist_report.dart';
import 'package:go4sheq/model/checklist_standard.dart';
import 'package:go4sheq/model/checklist_template_details.dart';
import 'package:go4sheq/model/employee_details.dart';
import 'package:go4sheq/model/notification_details.dart';
import 'package:go4sheq/model/task_details.dart';
import 'package:go4sheq/model/checklist_template.dart';
import 'package:go4sheq/model/user_login_details.dart';
import 'package:go4sheq/network/api_response.dart';
import 'package:go4sheq/repository/app_repository.dart';
import 'package:go4sheq/util/app_constant.dart';
import 'package:go4sheq/util/app_exception.dart';
import 'package:go4sheq/util/app_util.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppBloc with ChangeNotifier {
  /// App Repository
  final AppRepository _appRepository = AppRepository();

  /************************************* LOGIN *************************************/

  /// User Login Details
  ApiResponse<UserLoginDetails>? _userLoginDetails;
  User? _userDetails;

  ApiResponse<UserLoginDetails>? get userLoginDetails => _userLoginDetails;

  User? get userDetails => _userDetails;

  /************************************* TASK *************************************/

  /// Task Details List
  List<TaskDetails> _taskList = [];

  List<TaskDetails> get taskList => _taskList;

  List<TaskDetails> get taskPendingList {
    List<TaskDetails> tempList = [];
    for (int i = 0; i < _taskList.length; i++) {
      if (_taskList[i].taskStatusDetails?.name == 'Pending') {
        tempList.add(_taskList[i]);
      }
    }
    return tempList;
  }

  List<TaskDetails> get taskCompletedList {
    List<TaskDetails> tempList = [];
    for (int i = 0; i < _taskList.length; i++) {
      if (_taskList[i].taskStatusDetails?.name == 'Completed') {
        tempList.add(_taskList[i]);
      }
    }
    return tempList;
  }

  /// Task Details
  TaskDetails _taskDetails = TaskDetails();

  TaskDetails get taskDetails => _taskDetails;

  /************************************* NOTIFICATION *************************************/

  /// Notification Details List
  List<NotificationDetails> _notificationList = [];

  List<NotificationDetails> get notificationList => _notificationList;

  /************************************* LOGIN *************************************/

  /// User Login
  /// Fetching User login details
  userLogin({required String email, required String password}) async {
    _userLoginDetails = ApiResponse.loading('Fetching User login details');
    notifyListeners();

    try {
      final UserLoginDetails responseUserLoginDetails = await _appRepository.userLogin(email: email, password: password);

      var prefs = await SharedPreferences.getInstance();
      await prefs.setString(kPrefsUserEmail, email);
      await prefs.setString(kPrefsUserPassword, password);
      await prefs.setString(kPrefsToken, responseUserLoginDetails.token ?? "");

      _userDetails = responseUserLoginDetails.user;
      await FirebaseMessaging.instance.subscribeToTopic('${_userDetails?.id}');
      await _fetchUserDetails();
      await fetchTaskList(user: responseUserLoginDetails.user);
      await fetchChecklistAll(userId: responseUserLoginDetails.user?.id);
      _userLoginDetails = ApiResponse.completed(responseUserLoginDetails);
      notifyListeners();
    } catch (e) {
      _userLoginDetails = ApiResponse.error(e.toString());
      notifyListeners();
    }
  }

  /// Checking User logged in status
  Future<bool> isUserLoggedIn() async {
    var prefs = await SharedPreferences.getInstance();
    String token = prefs.getString(kPrefsToken) ?? '';

    if (token.isEmpty) return false;

    bool hasExpired = JwtDecoder.isExpired(token);
    Duration remainingTime = JwtDecoder.getRemainingTime(token);
    if (hasExpired || remainingTime.inDays < 2) return false;

    Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
    var tempUserLoginDetails = UserLoginDetails(
      token: token,
      user: User.fromJson(decodedToken),
      message: 'User already logged in successfully',
    );
    AppUtil.log(tempUserLoginDetails.toJson());
    _userDetails = tempUserLoginDetails.user;
    await FirebaseMessaging.instance.subscribeToTopic('${_userDetails?.id}');
    await _fetchUserDetails();
    await fetchTaskList(user: tempUserLoginDetails.user);
    await fetchChecklistAll(userId: tempUserLoginDetails.user?.id);
    _userLoginDetails = ApiResponse.completed(tempUserLoginDetails);
    notifyListeners();

    return true;
  }

  /// User Forget Password
  /// Sending email to user to reset password
  Future<String> userForgetPassword({required String email}) async {
    try {
      final String responseMessage = await _appRepository.userForgetPassword(email: email);

      return responseMessage;
    } catch (e) {
      throw AppException(e.toString());
    }
  }

  /// User Reset Password
  /// Changing user password
  Future<String> userResetPassword({required String password, required String confirmPassword}) async {
    try {
      var prefs = await SharedPreferences.getInstance();
      String email = prefs.getString(kPrefsUserEmail) ?? '';
      if (email.isEmpty) throw AppException('User email not found');

      final String responseMessage = await _appRepository.userResetPassword(email: email, password: password, confirmPassword: confirmPassword);

      return responseMessage;
    } catch (e) {
      throw AppException(e.toString());
    }
  }

  /// Making User logout
  userLogout() async {
    var prefs = await SharedPreferences.getInstance();
    await prefs.setString(kPrefsUserEmail, '');
    await prefs.setString(kPrefsUserPassword, '');
    await prefs.setString(kPrefsToken, '');
    _taskList = [];
    _checklistMy = [];
    _checklistAssign = [];
    _notificationList = [];
    await FirebaseMessaging.instance.unsubscribeFromTopic('${_userDetails?.id}');
    notifyListeners();
  }

  /// Pull down to refresh UserDetails, Task, Checklist
  Future<void> onRefresh() async {
    await _fetchUserDetails();
    final user = _userDetails;
    await fetchTaskList(user: user);
    await fetchChecklistAll(userId: user?.id);
  }

  /// Fetching User details
  _fetchUserDetails() async {
    try {
      final userId = _userDetails?.id;
      if (userId != null) {
        final User responseUser = await _appRepository.fetchUserDetails(userId: userId);

        _userDetails = responseUser;
        notifyListeners();
        // await _fetchCountryList();
      }
    } catch (e) {
      AppUtil.log(e);
    }
  }

  /************************************* MY PROFILE *************************************/

  /// Updating User details
  Future<String> updateUserDetails({required int userId, File? image, String? firstName, String? lastName, String? phoneNo, String? city, String? state, String? country}) async {
    try {
      final String responseMessage = await _appRepository.updateUserDetails(userId: userId, image: image, firstName: firstName, lastName: lastName, phoneNo: phoneNo, city: city, state: state, country: country);
      await _fetchUserDetails();

      return responseMessage;
    } catch (e) {
      throw AppException(e.toString());
    }
  }

  /// Changing User Password
  Future<String> changeUserPassword({required int userId, required String password, required String newPassword, required String confirmPassword}) async {
    try {
      final String responseMessage = await _appRepository.changeUserPassword(userId: userId, password: password, newPassword: newPassword, confirmPassword: confirmPassword);

      return responseMessage;
    } catch (e) {
      throw AppException(e.toString());
    }
  }

  /************************************* TASK *************************************/

  /// Fetching Employee List
  Future<List<EmployeeDetails>> fetchEmployeeList({required String searchKey}) async {
    int? companyId = _userDetails?.company?.id;
    if (companyId == null) return [];

    try {
      return await _appRepository.fetchEmployeeList(companyId: companyId, searchKey: searchKey);
    } catch (e) {
      AppUtil.log(e);
      return [];
    }
  }

  /// Fetching Task List
  fetchTaskList({User? user}) async {
    if (user?.id == null) return;

    try {
      _taskList = await _appRepository.fetchTaskList(user: user!);
      notifyListeners();
    } catch (e) {
      AppUtil.log(e);
    }
  }

  /// Opening CreateTask Screen
  openScreenTaskCreate({int? checklistId, int? sectionId, int? questionId}) {
    final user = _userDetails;
    _taskDetails = TaskDetails(
      assignedBy: EmployeeDetails(
        id: user?.id,
        firstName: user?.firstName,
        lastName: user?.lastName,
      ),
      id: null,
      name: '',
      description: '',
      assignedTo: EmployeeDetails(
        id: user?.id,
        firstName: user?.firstName,
        lastName: user?.lastName,
      ),
      taskStartDate: DateTime.now(),
      taskEndDate: null,
      taskCompletionDate: null,
      taskPriorityDetails: null,
      taskStatusDetails: kTaskStatusList[0],
      notes: null,
      completionNotes: null,
      file: [],
      filePath: [],
      checklistId: checklistId,
      sectionId: sectionId,
      questionId: questionId,
    );
    notifyListeners();
  }

  /// Task Create
  Future<String> taskCreate({required TaskDetails taskDetails}) async {
    try {
      final String responseMessage = await _appRepository.taskCreate(taskDetails: taskDetails);
      await fetchTaskList(user: _userDetails);

      return responseMessage;
    } catch (e) {
      throw AppException(e.toString());
    }
  }

  /// Opening CreateTask Screen for updating a task
  openScreenTaskUpdate({required TaskDetails taskDetails}) {
    _taskDetails = TaskDetails(
      assignedBy: taskDetails.assignedBy,
      id: taskDetails.id,
      name: taskDetails.name,
      description: taskDetails.description,
      assignedTo: taskDetails.assignedTo,
      taskStartDate: taskDetails.taskStartDate,
      taskEndDate: taskDetails.taskEndDate,
      taskCompletionDate: taskDetails.taskCompletionDate,
      taskPriorityDetails: taskDetails.taskPriorityDetails,
      taskStatusDetails: taskDetails.taskStatusDetails,
      notes: taskDetails.notes,
      completionNotes: taskDetails.completionNotes,
      file: taskDetails.file,
      filePath: [],
    );
    notifyListeners();
  }

  /// Task Update
  Future<String> taskUpdate({required TaskDetails taskDetails}) async {
    try {
      final String responseMessage = await _appRepository.taskUpdate(taskDetails: taskDetails);
      await fetchTaskList(user: _userDetails);

      return responseMessage;
    } catch (e) {
      throw AppException(e.toString());
    }
  }

  /************************************* NOTIFICATION *************************************/

  /// Fetching Notification List
  fetchNotificationList() async {
    final user = _userDetails;
    if (user?.id == null) return;

    try {
      _notificationList = await _appRepository.fetchNotificationList(user: user!);
      notifyListeners();
    } catch (e) {
      AppUtil.log(e);
    }
  }

  /// Update Notification
  updateNotification({required int index, bool? isRead, bool? isArchived}) async {
    final notification = _notificationList[index];
    if (notification.id == null) return;

    try {
      _notificationList[index] = await _appRepository.updateNotification(notificationId: notification.id!, isRead: isRead, isArchived: isArchived);
      notifyListeners();
    } catch (e) {
      AppUtil.log(e);
    }
  }
}
