class OrderModel {
  final String id;
  final String courtName;
  final String date;
  final String time;
  final String imageUrl;
  final String status;
  final String paymentMethod;
  final String? paymentNumber;
  final double price;

  OrderModel({
    required this.id,
    required this.courtName,
    required this.date,
    required this.time,
    required this.imageUrl,
    required this.status,
    required this.paymentMethod,
    this.paymentNumber,
    required this.price,
  });

  factory OrderModel.fromFirestore(Map<String, dynamic> json, String id) {
    return OrderModel(
      id: id,
      courtName: json['courtName'] ?? "Lapangan",
      date: json['date'] ?? "",
      time: json['time'] ?? "",
      imageUrl: json['imageUrl'] ?? "assets/default.jpg",
      status: json['status'] ?? "pending",
      paymentMethod: json['paymentMethod'] ?? "",
      paymentNumber: json['paymentNumber'],
      price: (json['totalCost'] ?? 0).toDouble(),
    );
  }
}
