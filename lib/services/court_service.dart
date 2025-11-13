import '../models/court.dart';

class CourtService {
// Mock data
  static final List<Court> _courts = [
    Court(
        id: '1',
        name: 'Lapangan A',
        location: 'Kecamatan X',
        pricePerHour: 100000,
        imageUrl: ''),
    Court(
        id: '2',
        name: 'Lapangan B',
        location: 'Kecamatan Y',
        pricePerHour: 80000,
        imageUrl: ''),
  ];

  Future<List<Court>> searchCourts(String query) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (query.isEmpty) return _courts;
    return _courts
        .where((c) =>
            c.name.toLowerCase().contains(query.toLowerCase()) ||
            c.location.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  Future<Court?> getCourtById(String id) async {
    return _courts.firstWhere((c) => c.id == id);
  }
}
