import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:mvvm_12/app_exception.dart';
import 'package:mvvm_12/network/base_api_services.dart';
import 'package:mvvm_12/shared/shared.dart';
import 'package:http/http.dart' as http;

class NetworkApiServices implements BaseApiServices {
  @override
  Future getApiResponse(String endpoint, {Map<String, String>? queryParams}) async {
    dynamic responseJson;
    try {
      final Uri uri = Uri.https(
        Const.baseUrl, 
        endpoint,
        queryParams, // Menambahkan query parameters ke URL
      );
      
      final response = await http.get(
        uri,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'key': Const.apiKey,
        },
      );
      responseJson = returnResponse(response);
    } on SocketException {
      throw NoInternetException('');
    } on TimeoutException {
      throw FetchDataException('Network request time out!');
    }

    return responseJson;
  }

  @override
  Future postApiResponse(String url, dynamic data) async {
    dynamic responseJson;
    try {
      final Uri uri = Uri.https(Const.baseUrl, url);

      // Menyusun body data menjadi format JSON
      final response = await http.post(
        uri,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'key': Const.apiKey,
        },
        body: jsonEncode(data), // Mengubah data menjadi JSON string
      );
      

      // Mengambil respons dan memprosesnya
      responseJson = returnResponse(response);
    } on SocketException {
      throw NoInternetException('');
    } on TimeoutException {
      throw FetchDataException('Network request time out!');
    }
    return responseJson;
  }

  dynamic returnResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
        dynamic responseJson = jsonDecode(response.body);
        return responseJson;
      case 400:
        throw BadRequestException(response.body.toString());
      case 500:
      case 404:
        throw UnauthorisedException(response.body.toString());
      default:
        throw FetchDataException(
            'Error occurred while communicating with server');
    }
  }
}
