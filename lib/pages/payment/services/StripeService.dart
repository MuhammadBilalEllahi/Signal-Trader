// import 'package:stripe/stripe_flutter.dart';

class StripeService {
  static final StripeService _instance = StripeService._internal();

  factory StripeService() => _instance;

  StripeService._internal();
  Future<void> makePayment(String amount) async {
    try {
      // final paymentIntent = await Stripe.instance.createPaymentIntent(amount);
    } catch (e) {
      print(e);
    }
  }
}
