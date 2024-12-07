import 'lib/screens/reports/create_report_screen.dart';
import 'lib/screens/reports/edit_report_screen.dart';

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import '../models/traffic_violation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../services/auth_service.dart';
import '../models/traffic_violation.dart';

var logger = Logger();

class ReportService {
  static final String _baseUrl = dotenv.env['API_URL'] ?? 'http://localhost:8000/reports';

  http.Client client;

  ReportService({http.Client? client}) : client = client ?? http.Client();

  Future<bool> createReport(
      TrafficViolation violation, List<XFile> mediaFiles) async {
    try {
      var url = Uri.parse('$_baseUrl/api/create-report/'); // 更新为新的API路径

      var reportJson = violation.toJson();

      var request = http.MultipartRequest('POST', Uri.parse(url as String));
      reportJson.forEach((key, value) {
        if (value != null) {
          request.fields[key] = value.toString();
        }
      });

      for (var file in mediaFiles) {
        var multipartFile =
            await http.MultipartFile.fromPath('media', file.path);
        request.files.add(multipartFile);
      }

      var response = await request.send();

      if (response.statusCode == 200) {
        return true;
      } else {
        logger.d('Failed to create report: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      logger.d('Caught error: $e');
      return false;
    }
  }

  Future<List<TrafficViolation>> getReports({int page = 1}) async {
    var url = Uri.parse('$_baseUrl/api/traffic-violations-list/?page=$page');

    // 使用 AuthService 获取 JWT token
    var token = await AuthService.getAccessToken(); // 如果 _getToken 是私有的，请更改为 public 或在 AuthService 内部调用它

    var response = await http.get(
      url,
      // 将 token 添加到请求的 headers 中
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => TrafficViolation.fromJson(json)).toList();
    } else {
      logger.d('Failed to fetch reports: ${response.statusCode}');
      return [];
    }
  }

  // 獲取特定違規報告的方法
  Future<TrafficViolation> getViolation(int recordId) async {
    var url = Uri.parse('$_baseUrl/api/traffic-violations-detail/'); // 更新为新的API路径
    var response = await http.get(Uri.parse('$url$recordId/'));

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      return TrafficViolation.fromJson(data);
    } else {
      logger.d('Failed to fetch violation: ${response.statusCode}');
      throw Exception('Failed to fetch violation');
    }
  }

  // 更新报告的方法，现在包括本地和远程媒体文件的处理
  Future<bool> updateReport(TrafficViolation violation,
      {List<XFile>? localMediaFiles, List<String>? remoteMediaFiles}) async {
    try {
      var url = Uri.parse('$_baseUrl/api/update-report/${violation.id}/');

      var reportJson = violation.toJson();

      var request = http.MultipartRequest('PUT', url);

      // 设置请求头，例如身份验证标头
      // request.headers['Authorization'] = 'Bearer $token';

      reportJson.forEach((key, value) {
        if (value != null) {
          request.fields[key] = value.toString();
        }
      });

      // 添加本地媒体文件
      if (localMediaFiles != null) {
        for (var file in localMediaFiles) {
          var field = 'media'; // 请确保与后端API的约定一致
          var multipartFile =
              await http.MultipartFile.fromPath(field, file.path);
          request.files.add(multipartFile);
        }
      }

      // 处理远程媒体文件
      if (remoteMediaFiles != null) {
        request.fields['remoteMediaFiles'] = jsonEncode(remoteMediaFiles);
      }

      var response = await request.send();

      if (response.statusCode == 200) {
        return true;
      } else {
        logger.d('Failed to update report: ${response.statusCode}');
        // 返回更具体的错误信息
        return false;
      }
    } on SocketException catch (e) {
      logger.d('Network error: $e');
      // 返回网络错误信息
      return false;
    } on HttpException catch (e) {
      logger.d('HTTP error: $e');
      // 返回HTTP错误信息
      return false;
    } catch (e) {
      logger.d('Caught error: $e');
      // 返回其他错误信息
      return false;
    }
  }
}
