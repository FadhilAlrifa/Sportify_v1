class OrderModel {
  final String courtName;
  final String date;
  final String time;
  final int price;
  final String status;

  OrderModel({
    required this.courtName,
    required this.date,
    required this.time,
    required this.price,
    required this.status,
  });
}

List<OrderModel> dummyHistory = [
  OrderModel(
    courtName: "Lapangan Futsal A",
    date: "2025-01-12",
    time: "14:00 - 15:00",
    price: 50000,
    status: "Completed",
  ),
  OrderModel(
    courtName: "Lapangan Badminton B",
    date: "2025-01-08",
    time: "09:00 - 10:00",
    price: 30000,
    status: "Canceled",
  ),
];
