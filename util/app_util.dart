import 'dart:developer' as developer;
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:go4sheq/util/app_constant.dart';
import 'package:open_file/open_file.dart';
import 'package:url_launcher/url_launcher.dart';

class AppUtil {
  static log(Object? object) {
    if (kDebugMode) {
      print(object);
    }
  }

  static logMsg(Object? object) {
    if (kDebugMode) {
      developer.log(object.toString());
    }
  }

  static hideKeyboard(BuildContext context) {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  /// https://pub.dev/packages/url_launcher
  static openFileFromUrl(String fileName) async {
    try {
      final Uri url = Uri.parse('$kImageUrl$fileName');
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      AppUtil.log(e);
    }
  }

  /// https://pub.dev/packages/open_file
  static openFile(String filePath) {
    OpenFile.open(filePath);
  }

  /// Returns a URL that can be launched on the current platform
  /// to open a maps application showing coordinates ([latitude] and [longitude]).
  static createCoordinatesUrl(double latitude, double longitude, [String? label]) {
    Uri url;

    if (Platform.isAndroid) {
      var query = '$latitude,$longitude';
      if (label != null) query += '($label)';
      url = Uri(scheme: 'geo', host: '0,0', queryParameters: {'q': query});
    } else if (Platform.isIOS) {
      // TODO: Test apple maps in ios
      var params = {'ll': '$latitude,$longitude'};
      if (label != null) params['q'] = label;
      url = Uri.https('maps.apple.com', '/', params);
    } else {
      url = Uri.https('www.google.com', '/maps/search/', {'api': '1', 'query': '$latitude,$longitude'});
    }

    return url;
  }

  /// Launches the maps application for this platform.
  /// The maps application will show the specified coordinates.
  static launchCoordinates(double latitude, double longitude, [String? label]) async {
    try {
      await launchUrl(createCoordinatesUrl(latitude, longitude, label), mode: LaunchMode.externalApplication);
    } catch (e) {
      AppUtil.log(e);
    }
  }
}

extension HexString on String {
  int getHexValue() => int.parse(replaceAll('#', '0xff'));
}

extension DateString on DateTime {
  String getString({String separator = '/'}) => '$day$separator$month$separator$year';
}
