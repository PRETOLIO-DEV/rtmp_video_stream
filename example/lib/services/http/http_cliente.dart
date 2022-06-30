import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';

import 'http_error.dart';
import "package:http/http.dart" as http;


class HttpCli {


  Future get(
      {required String? url, Map<String, String>? headers, bool decoder = true, bool bits = false,}) async {

    try{
      final http.Response response = await http.get(
          Uri.parse(url ?? ''), headers: headers,

      ).timeout(const Duration(seconds: 10), onTimeout : () {
        debugPrint('get timeout');
        throw HttpError.timeout;
      }).catchError((onError){
        debugPrint('catchError ' + onError.toString());
        throw HttpError.unexpected;
      });
      if(response.statusCode == 200){
        var result = bits ? response.bodyBytes : decoder ? json.decode(response.body) : response.body;
        return result;
      }else {
        debugPrint(response.statusCode.toString());
        debugPrint(response.body.toString());
        throw response.statusCode;
      }

    } catch(e){
      debugPrint('catch' + e.toString());
      throw e;
    }
  }

  Future post({required String url, required Map<String, String> headers,
      required Map<String, dynamic> body, bool decoder = true}) async {

    try{

      final http.Response response = await http.post(
        Uri.parse(url), headers: headers, body: jsonEncode(body)
      ).timeout(const Duration(seconds: 10), onTimeout : () {
        debugPrint('post timeout');
        throw HttpError.timeout;
      }).catchError((onError){
        debugPrint('catchError ' + onError.toString());
        throw HttpError.unexpected;
      });

      if(response.statusCode == 200){
        final result =  decoder ? json.decode(response.body) : response.body;
        return result;
      }else {
        debugPrint(response.statusCode.toString());
        debugPrint(response.body.toString());
        throw response.statusCode;
      }
    }  catch(e){
      debugPrint('catch' + e.toString());
      throw HttpError.unexpected;
    }
  }

  Future put({required String url, required Map<String, String> headers,
        Map<String, dynamic>? body, bool decoder = true}) async {

    try{
      final http.Response response = await http.put(
        Uri.parse(url), headers: headers,
        body: body
      ).timeout(const Duration(seconds: 10), onTimeout : () {
        debugPrint('get timeout');
        throw HttpError.timeout;
      }).catchError((onError){
        debugPrint('catchError ' + onError.toString());
        throw HttpError.unexpected;
      });
      if(response.statusCode == 200){
        final result = decoder ? json.decode(response.body) : response.body;
        return result;
      }else {
        debugPrint(response.statusCode.toString());
        debugPrint(response.body.toString());
        throw response.statusCode;
      }
    } catch(e){
      debugPrint('catch' + e.toString());
      throw HttpError.unexpected;
    }
  }
}