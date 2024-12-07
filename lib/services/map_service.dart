import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/traffic_violation.dart';

class MapService {
  final Set<Marker> _markers = {};
  final String _baseUrl = dotenv.env['API_URL'] ?? 'http://localhost:8000/';

  Set<Marker> get markers => _markers;

  Future<Set<Marker>> loadMarkers(Function(String) onMarkerTapped) async {
    var url = Uri.parse('$_baseUrl/api/traffic-violation-markers/');
    var response = await http.get(url);
    Set<Marker> markers = {};

    if (response.statusCode == 200) {
      var decodedBody = utf8.decode(response.bodyBytes);
      List<dynamic> data = json.decode(decodedBody);

      for (var markerData in data) {
        var lat = markerData['lat'];
        var lng = markerData['lng'];
        var license_plate = markerData['license_plate'];
        var violation = markerData['violation'];
        

        if (lat == null || lng == null) {
          debugPrint('Error: latitude or longitude is null.');
          continue;
        }

        try {
          String markerTitle = '${license_plate ?? 'Unknown'}-${violation ?? 'Unknown'}';
          final marker = Marker(
            markerId: MarkerId(markerData['id'].toString()),
            position: LatLng(
              double.parse(lat.toString()),
              double.parse(lng.toString()),
            ),
            infoWindow: InfoWindow(
              title: markerTitle,
            ),
            onTap: () => onMarkerTapped(markerData['traffic_violation_id'].toString()),
          );

          markers.add(marker);
        } catch (e) {
          debugPrint('Error parsing latitude or longitude: $e');
        }
      }
      return markers; // 返回加载的标记
    } else {
      throw Exception(
          'Failed to load markers. Status code: ${response.statusCode}');
    }
  }

  Future<TrafficViolation?> getTrafficViolationDetails(
      String trafficViolationId) async {
    var url =
        Uri.parse('$_baseUrl/api/traffic-violation-details/$trafficViolationId/');
        // print(url);
    var response = await http.get(url);

    if (response.statusCode == 200) {
      var decodedBody = utf8.decode(response.bodyBytes);
      // List<dynamic> data = json.decode(decodedBody);
      var data = json.decode(decodedBody);
      // print(data);
      return TrafficViolation.fromJson(data);
    } else {
      throw Exception(
          'Failed to load traffic violation details. Status code: ${response.statusCode}');
    }
  }

  Future<void> searchData(String keyword, DateTimeRange? dateRange,
      Function(Set<Marker>) onSearchComplete) async {
    // This is a placeholder for the search logic. You would need to implement the actual search
    // logic based on your backend API's capabilities. The following is a simple example that
    // filters markers by a keyword in the title.
    Set<Marker> filteredMarkers = _markers.where((marker) {
      return marker.infoWindow.title
              ?.toLowerCase()
              .contains(keyword.toLowerCase()) ??
          false;
    }).toSet();

    // If a date range is provided, further filter the markers by date.
    if (dateRange != null) {
      // Assuming each marker has an associated date in the format 'yyyy-MM-dd'.
      filteredMarkers = filteredMarkers.where((marker) {
        // Extract the date from the marker's snippet and convert it to a DateTime object.
        DateTime markerDate = DateTime.parse(marker.infoWindow.snippet ?? '');
        // Check if the marker's date falls within the selected date range.
        return markerDate.isAfter(dateRange.start) &&
            markerDate.isBefore(dateRange.end);
      }).toSet();
    }

    onSearchComplete(filteredMarkers);
  }
}
