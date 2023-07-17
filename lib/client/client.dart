import 'package:dio/dio.dart';

class Client {
  final client = Dio(BaseOptions(baseUrl: baseUrl));
  static const String baseUrl = "http://127.0.0.1";
  static const String locationAdd = "/location";

}