import 'dart:convert';
import 'dart:developer';
import 'package:estoque/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'constants/constants.dart';
import 'package:http/http.dart' as http;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await firebaseInitialization.then((value) {
    Get.put(AuthController());
  });
  runApp(
      const GetMaterialApp(debugShowCheckedModeBanner: false, home: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class PaymentDemo extends StatelessWidget {
  const PaymentDemo({super.key});

  Future<void> initPayment(
      {required String email, required double amount}) async {
    try {
      //create a payment intent on the server
      final response = await http.post(
          Uri.parse(
              'https://us-central1-estoque-7d7bf.cloudfunctions.net/stripePaymentIntentRequest'),
          body: {'email': email, 'amount': amount});
      final jsonResponse = jsonDecode(response.body);
      log(jsonResponse.toString());
      //initialize the payment sheet
      Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: jsonResponse['paymentIntent'],
        merchantDisplayName: 'É u Eds',
        customerId: jsonResponse['customer'],
        customerEphemeralKeySecret: jsonResponse['ephemeralKey'],
      ));
      await Stripe.instance.presentPaymentSheet();
      Get.snackbar('Pagamento concluido!', '');
    } catch (error) {
      if (error is StripeException) {
        Get.snackbar('Ocorreu um erro', '${error.error.localizedMessage}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          child: const Text('Comprar Prime'),
          onPressed: () async {
            await initPayment(email: 'emailtest@gmail.com', amount: 1.0);
          },
        ),
      ),
    );
  }
}
