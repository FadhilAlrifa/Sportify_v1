import 'package:flutter/material.dart';
import '../models/court.dart';
import '../services/court_service.dart';

class CourtProvider extends ChangeNotifier {
  final CourtService _service = CourtService();
  List<Court> courts = [];
  bool loading = false;

  Future<void> search(String query) async {
    loading = true;
    notifyListeners();
    courts = await _service.searchCourts(query);
    loading = false;
    notifyListeners();
  }
}
