import 'package:flutter/material.dart';
import 'package:go4sheq/model/task_priority_details.dart';
import 'package:go4sheq/model/task_status_details.dart';

/// Network Constant
const String kBaseUrl = "http://developer24x7.com:9000/";
const String kImageUrl = "${kBaseUrl}download/";

const int kHttpTimeoutSec = 10;
const String kHttpTimeoutMsg = "The connection has timed out, Please try again!";

/// SharedPreferences Constant
const kPrefsUserEmail = "user_email";
const kPrefsUserPassword = "user_password";
const kPrefsToken = "token";
const kPrefsLanguageCode = "language_code";

/// Regular Expression
final RegExp kRegExpEmail = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
final RegExp kRegExpPhone = RegExp(r"^[6-9][0-9]{9}$");
// 8-16 characters, at least 1 uppercase letter, 1 lowercase letter, 1 number and 1 special character
final RegExp kRegExpPassword = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*#?&])[A-Za-z\d@$!%*#?&]{8,16}$');

/// Color
const kColorBlueDeep = Color(0xff0471DB);
const kColorBlueLight = Color(0xff09C5F2);

const kColorWhiteSilver = Color(0xffC4C4C4);

const kColorBackground = Colors.white;

/// Gradient
const kGradientScreenBackground = LinearGradient(
  colors: <Color>[
    kColorBlueDeep,
    kColorBlueLight,
  ],
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
);
const kGradientScreenBackgroundHome = LinearGradient(
  colors: <Color>[
    kColorBlueLight,
    kColorBlueDeep,
  ],
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
);

/// InputDecoration
const kTextFieldDecoration = InputDecoration(
  // labelText: '',
  labelStyle: TextStyle(color: Colors.grey),
  // hintText: '',
  // hintStyle: Theme.of(context).textTheme.subtitle1,
  // filled: true,
  // fillColor: kColorWhite,
  contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 12.0),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(4.0)),
  ),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: kColorWhiteSilver, width: 0.5),
    borderRadius: BorderRadius.all(Radius.circular(4.0)),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: kColorWhiteSilver, width: 1.0),
    borderRadius: BorderRadius.all(Radius.circular(4.0)),
  ),
);

/// Task Status Details List
final List<TaskStatusDetails> kTaskStatusList = [
  TaskStatusDetails(id: 1, name: 'Pending', color: const Color(0xff0471DB)),
  TaskStatusDetails(id: 2, name: 'Completed', color: const Color(0xff3a9425)),
];

/// Task Priority Details List
final List<TaskPriorityDetails> kTaskPriorityList = [
  TaskPriorityDetails(id: 1, name: 'Critical', icon: 'icon_priority_critical.png', color: const Color(0xffbb0013)),
  TaskPriorityDetails(id: 2, name: 'High', icon: 'icon_priority_high.png', color: const Color(0xffe07a2a)),
  TaskPriorityDetails(id: 3, name: 'Medium', icon: 'icon_priority_medium.png', color: const Color(0xff6ca134)),
  TaskPriorityDetails(id: 4, name: 'Low', icon: 'icon_priority_low.png', color: const Color(0xff485daa)),
];
