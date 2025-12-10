import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/court.dart'; // Pastikan ini mengarah ke file model Anda

class CourtProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- STATE VARIABLES ---
  List<CourtModel> _courts = [];          // Menyimpan SEMUA data dari Firebase
  List<CourtModel> _filteredCourts = [];  // Menyimpan data yang DITAMPILKAN (hasil search)
  bool _isLoading = false;

  // --- GETTERS ---
  // UI hanya mengambil data dari _filteredCourts
  List<CourtModel> get courts => _filteredCourts;
  bool get isLoading => _isLoading;

  // ==========================================================
  // 1. FITUR USER (FETCH & SEARCH)
  // ==========================================================

  /// Mengambil semua data lapangan dari Firestore
  Future<void> fetchCourts() async {
    try {
      _isLoading = true;
      notifyListeners();

      final snapshot = await _firestore.collection('venues').get();

      _courts = snapshot.docs.map((doc) {
        try {
          return CourtModel.fromMap(doc.data(), doc.id);
        } catch (e) {
          print("Error parsing court data: $e");
          return null;
        }
      }).whereType<CourtModel>().toList(); // Hapus data yang null/gagal parse

      // Saat awal load, data yang ditampilkan = semua data
      _filteredCourts = _courts;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print("Error fetching courts: $e");
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Melakukan pencarian lokal berdasarkan Nama atau Alamat
  void searchCourts(String query) {
    if (query.isEmpty) {
      // Jika search bar kosong, kembalikan ke list penuh
      _filteredCourts = _courts;
    } else {
      // Filter list berdasarkan query
      _filteredCourts = _courts.where((court) {
        final nameLower = court.name.toLowerCase();
        final locationLower = court.address.toLowerCase();
        final searchLower = query.toLowerCase();

        return nameLower.contains(searchLower) || 
               locationLower.contains(searchLower);
      }).toList();
    }
    notifyListeners();
  }

  // ==========================================================
  // 2. FITUR VENDOR (ADD & DELETE)
  // ==========================================================

  /// Menambahkan lapangan baru ke Firestore
  Future<String?> addVenue(Map<String, dynamic> data) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Upload ke Firebase
      await _firestore.collection('venues').add(data);

      // Refresh data lokal agar lapangan baru langsung muncul di list tanpa restart app
      await fetchCourts(); 

      _isLoading = false;
      notifyListeners();
      return null; // Null artinya Sukses
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return "Gagal menambah lapangan: $e";
    }
  }

  /// Menghapus lapangan berdasarkan Document ID
  Future<void> deleteVenue(String docId) async {
    try {
      // Hapus dari Firebase
      await _firestore.collection('venues').doc(docId).delete();
      
      // Hapus dari list lokal juga biar UI langsung update
      _courts.removeWhere((item) => item.id == docId);
      _filteredCourts.removeWhere((item) => item.id == docId);
      
      notifyListeners();
    } catch (e) {
      print("Gagal menghapus: $e");
      rethrow; // Lempar error agar bisa ditangkap di UI (untuk SnackBar)
    }
  }
}