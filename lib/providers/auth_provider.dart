import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthProvider with ChangeNotifier {
  // Instance Firebase
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Variabel User saat ini
  User? _user;
  User? get user => _user;

  // Cek apakah user sedang login
  bool get isLoggedIn => _user != null;

  AuthProvider() {
    _init();
  }

  // Listener: Mendeteksi perubahan status login secara otomatis
  // (Misal: User menutup aplikasi lalu membukanya lagi)
  void _init() {
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners(); // Kabari UI bahwa status login berubah
    });
  }

  // --- FUNGSI LOGIN ---
  // Mengembalikan String? (Null jika sukses, Pesan Error jika gagal)
  Future<String?> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null; // SUKSES
    } on FirebaseAuthException catch (e) {
      // Error spesifik dari Firebase (misal: password salah)
      return e.message;
    } catch (e) {
      return "Terjadi kesalahan: $e";
    }
  }

  // --- FUNGSI REGISTER ---
  // Menerima Nama, Email, Password
  Future<String?> register(String name, String email, String password) async {
    try {
      // 1. Buat Akun di Authentication
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 2. Simpan Data Tambahan ke Firestore Database
      if (cred.user != null) {
        // Update Nama di Profil Auth (biar mudah diakses)
        await cred.user!.updateDisplayName(name);

        // Simpan ke koleksi 'users'
        await _firestore.collection('users').doc(cred.user!.uid).set({
          'uid': cred.user!.uid,
          'name': name,
          'email': email,
          'createdAt': DateTime.now().toIso8601String(),
          'role': 'user', // Default role
          'profileImage': '', // Kosong dulu
        });
      }
      return null; // SUKSES
    } on FirebaseAuthException catch (e) {
      return e.message; // Kembalikan pesan error asli dari Firebase
    } catch (e) {
      return "Gagal mendaftar: $e";
    }
  }

  // --- FUNGSI LOGOUT ---
  Future<void> logout() async {
    await _auth.signOut();
    // notifyListeners() tidak perlu dipanggil manual, 
    // karena listener di _init() otomatis mendeteksi perubahan ini.
  }
}