import 'dart:io';
import 'dart:convert';
import 'package:go4sheq/util/app_exception.dart';
import 'package:go4sheq/util/app_constant.dart';
import 'package:go4sheq/util/app_util.dart';
import 'package:http/http.dart' as http;

class ApiBaseHelper {
  static const String _tag = "ApiBaseHelper ~ ";

  /// GET
  Future<dynamic> get(String endpoint, {Map<String, String>? headers}) async {
    dynamic responseJson;
    try {
      AppUtil.log("$_tag$endpoint");
      final response = await http.get(Uri.parse(kBaseUrl + endpoint), headers: headers).timeout(
        const Duration(seconds: kHttpTimeoutSec),
        onTimeout: () {
          throw AppException(kHttpTimeoutMsg);
        },
      );
      responseJson = _returnResponse(response);
    } on SocketException {
      AppUtil.log("${_tag}Exception: No Internet connection");
      throw AppException('No Internet connection');
    } catch (e) {
      if (e.toString().isEmpty) {
        AppUtil.log("${_tag}Exception: Execution Failed. Try Again!");
        throw AppException("Execution Failed. Try Again!");
      }
      throw AppException(e);
    }
    return responseJson;
  }

  /// POST
  Future<dynamic> post(String endpoint, {Map<String, String>? headers, Object? body}) async {
    dynamic responseJson;
    try {
      AppUtil.log("$_tag$endpoint");
      if (body != null) AppUtil.log(_tag + body.toString());
      final response = await http.post(Uri.parse(kBaseUrl + endpoint), headers: headers, body: body).timeout(
        const Duration(seconds: kHttpTimeoutSec),
        onTimeout: () {
          throw AppException(kHttpTimeoutMsg);
        },
      );
      responseJson = _returnResponse(response);
    } on SocketException {
      AppUtil.log("${_tag}Exception: No Internet connection");
      throw AppException('No Internet connection');
    } catch (e) {
      if (e.toString().isEmpty) {
        AppUtil.log("${_tag}Exception: Execution Failed. Try Again!");
        throw AppException("Execution Failed. Try Again!");
      }
      throw AppException(e);
    }
    return responseJson;
  }

  /// PUT
  Future<dynamic> put(String endpoint, {Map<String, String>? headers, Object? body}) async {
    dynamic responseJson;
    try {
      AppUtil.log("$_tag$endpoint");
      if (body != null) AppUtil.log(_tag + body.toString());
      final response = await http.put(Uri.parse(kBaseUrl + endpoint), headers: headers, body: body).timeout(
        const Duration(seconds: kHttpTimeoutSec),
        onTimeout: () {
          throw AppException(kHttpTimeoutMsg);
        },
      );
      responseJson = _returnResponse(response);
    } on SocketException {
      AppUtil.log("${_tag}Exception: No Internet connection");
      throw AppException('No Internet connection');
    } catch (e) {
      if (e.toString().isEmpty) {
        AppUtil.log("${_tag}Exception: Execution Failed. Try Again!");
        throw AppException("Execution Failed. Try Again!");
      }
      throw AppException(e);
    }
    return responseJson;
  }

  /// DELETE
  Future<dynamic> delete(String endpoint, {Map<String, String>? headers, Object? body}) async {
    dynamic responseJson;
    try {
      AppUtil.log("$_tag$endpoint");
      if (body != null) AppUtil.log(_tag + body.toString());
      final response = await http.delete(Uri.parse(kBaseUrl + endpoint), headers: headers, body: body).timeout(
        const Duration(seconds: kHttpTimeoutSec),
        onTimeout: () {
          throw AppException(kHttpTimeoutMsg);
        },
      );
      responseJson = _returnResponse(response);
    } on SocketException {
      AppUtil.log("${_tag}Exception: No Internet connection");
      throw AppException('No Internet connection');
    } catch (e) {
      if (e.toString().isEmpty) {
        AppUtil.log("${_tag}Exception: Execution Failed. Try Again!");
        throw AppException("Execution Failed. Try Again!");
      }
      throw AppException(e);
    }
    return responseJson;
  }

  /// Decode Response
  dynamic _returnResponse(http.Response response) {
    AppUtil.log(_tag + response.statusCode.toString());

    switch (response.statusCode) {
      case 200:
        var responseJson = json.decode(response.body.toString());
        AppUtil.log(_tag + responseJson.toString());
        return responseJson;
      case 301:
      case 400:
      case 401:
      case 402:
      case 403:
      case 404:
      case 409:
      case 422:
      case 500:
        Map<String, dynamic> responseFailureJson = json.decode(response.body.toString());
        String? errorMsg = responseFailureJson['message'];
        if (errorMsg != null) {
          AppUtil.log("${_tag}Exception: $errorMsg");
          throw AppException(errorMsg);
        }
        AppUtil.log("${_tag}Exception: ");
        throw AppException("Error status: ${response.statusCode}");
      default:
        AppUtil.log("${_tag}Exception: ");
        throw AppException("Error status: ${response.statusCode}");
    }
  }
}
