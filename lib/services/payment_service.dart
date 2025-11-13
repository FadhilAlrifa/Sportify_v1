class PaymentService {
// Mock charging function — diintegrasikan dengan provider sebenarnya (Stripe/Paypal/Bank)
  Future<bool> pay({required String userId, required double amount}) async {
    await Future.delayed(const Duration(seconds: 2));
    return true; // return false jika gagal
  }
}
