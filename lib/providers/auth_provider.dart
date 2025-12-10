import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthProvider with ChangeNotifier {
  // Instance Firebase
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Variabel State
  User? _user;
  String? _role; // Menyimpan role: 'user' atau 'vendor'

  // Getters untuk diakses UI
  User? get user => _user;
  String? get role => _role;
  bool get isLoggedIn => _user != null;

  // Constructor: Jalankan listener saat provider dibuat
  AuthProvider() {
    _init();
  }

  // --- 1. INISIALISASI (AUTO LOGIN) ---
  void _init() {
    _auth.authStateChanges().listen((User? user) async {
      _user = user;
      
      if (user != null) {
        // Jika user ditemukan (sedang login), ambil Role-nya dari database
        await _fetchUserRole(user.uid);
      } else {
        // Jika logout, kosongkan role
        _role = null;
      }
      notifyListeners();
    });
  }

  // --- 2. FUNGSI AMBIL ROLE DARI FIRESTORE ---
  Future<void> _fetchUserRole(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        // Ambil field 'role', jika tidak ada default ke 'user'
        _role = doc.data()?['role'] ?? 'user';
        notifyListeners();
      }
    } catch (e) {
      print("Error mengambil role: $e");
    }
  }

  // --- 3. FUNGSI LOGIN ---
  Future<String?> login(String email, String password) async {
    try {
      // a. Login ke Authentication
      UserCredential cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // b. Segera ambil data Role agar UI tahu harus ke halaman mana
      if (cred.user != null) {
        await _fetchUserRole(cred.user!.uid);
      }

      return null; // Sukses (return null artinya tidak ada error)
    } on FirebaseAuthException catch (e) {
      return e.message; // Kembalikan pesan error dari Firebase
    } catch (e) {
      return "Gagal login: $e";
    }
  }

  // --- 4. FUNGSI REGISTER (Updated dengan Role) ---
  Future<String?> register(String name, String email, String password, {String role = 'user'}) async {
    try {
      // a. Buat Akun di Authentication
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // b. Simpan Data User + Role ke Firestore
      if (cred.user != null) {
        // Update Nama di Auth Profil
        await cred.user!.updateDisplayName(name);

        // Simpan data lengkap ke database
        await _firestore.collection('users').doc(cred.user!.uid).set({
          'uid': cred.user!.uid,
          'name': name,
          'email': email,
          'role': role, // <--- PENTING: Role disimpan di sini
          'createdAt': DateTime.now().toIso8601String(),
          'profileImage': '', 
        });

        // Set role di memori lokal agar aplikasi langsung tahu
        _role = role;
        notifyListeners();
      }
      return null; // Sukses
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return "Gagal mendaftar: $e";
    }
  }

  // --- 5. FUNGSI LOGOUT (Ini yang dibutuhkan ProfileScreen) ---
  Future<void> logout() async {
    await _auth.signOut();
    _role = null;
    notifyListeners(); // Memberi tahu main.dart untuk refresh ke LoginScreen
  }
}