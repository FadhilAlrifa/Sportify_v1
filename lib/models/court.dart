class CourtModel {
  final String id;
  final String name;
  final String address;
  final String imageUrl;
  final String type; // Contoh: Futsal, Badminton
  final double rating;
  final int price;
  final String description; // Deskripsi lapangan
  final List<String> facilities; // Daftar fasilitas (WiFi, Parkir, dll)

  CourtModel({
    required this.id,
    required this.name,
    required this.address,
    required this.imageUrl,
    required this.type,
    required this.rating,
    required this.price,
    required this.description,
    required this.facilities,
  });

  // Factory constructor untuk mengubah data JSON (Map) dari Firebase menjadi Object Dart
  factory CourtModel.fromMap(Map<String, dynamic> data, String docId) {
    return CourtModel(
      id: docId,
      name: data['name'] ?? '',
      address: data['address'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      type: data['type'] ?? 'Umum',
      
      // Konversi aman untuk angka (menghindari error int vs double)
      rating: (data['rating'] ?? 0.0).toDouble(),
      price: (data['price'] ?? 0).toInt(),
      
      description: data['description'] ?? '',
      
      // Konversi aman untuk List
      // Mengambil array 'facilities', jika null jadikan list kosong []
      facilities: List<String>.from(data['facilities'] ?? []),
    );
  }
}