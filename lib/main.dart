import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:tradingapp/firebase_options.dart';
import 'package:tradingapp/pages/auth/AuthGate.dart';
import 'package:tradingapp/pages/auth/services/AuthService.dart';
import 'package:tradingapp/pages/auth/services/ThemeService.dart';
import 'package:tradingapp/pages/auth/services/UserService.dart';
import 'package:tradingapp/shared/constants/app_constants.dart';
import 'package:tradingapp/theme/theme.dart';
import 'package:tradingapp/pages/newsAlerts/providers/news_alerts_provider.dart';
import 'package:tradingapp/pages/signals/providers/signals_provider.dart';
import 'package:tradingapp/pages/root/profile/providers/profile_provider.dart';
import 'package:tradingapp/pages/root/home/providers/crypto_price_provider.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "./.env");
  await Firebase.initializeApp(
    // name: AppConstants.appName,
    options: DefaultFirebaseOptions.currentPlatform);

  runApp(
      MultiProvider(providers: [
        ChangeNotifierProvider(create: (create)=>UserService()),
        ChangeNotifierProvider(create: (create)=>AuthService()),
        ChangeNotifierProvider(create: (create)=>ThemeService(ThemeMode.light)),
        ChangeNotifierProvider(create: (_) => NewsAlertsProvider()),
        ChangeNotifierProvider(create: (_) => SignalsProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => CryptoPriceProvider()),
      ]
      ,
      child:const MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

    final updater = ShorebirdUpdater();

  @override
  void initState() {
    super.initState();

    // Get the current patch number and print it to the console.
    // It will be `null` if no patches are installed.
    updater.readCurrentPatch().then((currentPatch) {
      print('The current patch number is: ${currentPatch?.number}');
    });
  }

  Future<void> _checkForUpdates() async {
    // Check whether a new update is available.
    final status = await updater.checkForUpdate();

    if (status == UpdateStatus.outdated) {
      try {
        // Perform the update
        await updater.update();
      } on UpdateException catch (error) {
        // Handle any errors that occur while updating.
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppConstants.appName,
      theme: MyTheme.lightTheme,
      darkTheme: MyTheme.darkTheme,

      initialRoute: AppRoutes.authGate,

      routes: {
        AppRoutes.authGate : (context)=> AuthGate(),
        // AppRoutes.signIn: (context)=> SignIn(changeSignIn: changeSignIn),
        // AppRoutes.signUp: (context)=> SignIn(changeSignIn: changeSignIn),
        // AppRoutes.splashScreen : (context)=> GetStartedScreen()

      },
    );
  }
}
