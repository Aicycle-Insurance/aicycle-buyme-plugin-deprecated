import 'dart:io';

import 'package:aicycle_buyme_plugin/common/di/di_setup.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';

import '../constants/constants.dart';

class ErrorHandling implements Exception {
  String errorMessage = "";
  final Dio dio = getIt<Dio>();

  ErrorHandling.withError({
    required DioError error,
  }) {
    _handleError(error);
  }

  Future _handleError(DioError error) async {
    switch (error.type) {
      case DioErrorType.cancel:
        errorMessage = "dio_cancel_request".tr();
        break;
      case DioErrorType.connectTimeout:
        errorMessage = "dio_cancel_request".tr();
        break;
      case DioErrorType.other:
        errorMessage = "dio_cancel_request".tr();
        if (error.error is SocketException) {
          errorMessage = "no_internet".tr();
        }
        break;
      case DioErrorType.receiveTimeout:
        errorMessage = "dio_cancel_request".tr();
        break;
      case DioErrorType.sendTimeout:
        errorMessage = "dio_cancel_request".tr();
        break;
      case DioErrorType.response:
        final code = error.response?.statusCode;

        //handle refresh Token
        // if (error.type == StatusCode.refreshToken){
        //   await refreshToken(error);
        //   return;
        // }
        if (code == StatusCode.unauthorized) {
          errorMessage =
              (error.response?.data as Map)['message'] ?? 'unauthorized'.tr();
        } else {
          //todo: handle message =>
          errorMessage = 'systemError'.tr();
        }
        break;
      default:
        break;
    }

    return errorMessage;
  }

  Future<void> refreshToken(DioError error) async {
    error.requestOptions.cancelToken?.cancel();
    String token = "";
    //get new Token
    final headers = error.requestOptions.headers;
    headers['Authorization'] = token;
    final opts = Options(method: error.requestOptions.method, headers: headers);
    await dio.request(
      error.requestOptions.path,
      options: opts,
      data: error.requestOptions.data,
      queryParameters: error.requestOptions.queryParameters,
    );
  }
}
