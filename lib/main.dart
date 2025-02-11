import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tradingapp/pages/UI/GetStarted.dart';
import 'package:tradingapp/pages/auth/AuthGate.dart';
import 'package:tradingapp/pages/auth/SignIn.dart';
import 'package:tradingapp/pages/services/AuthService.dart';
import 'package:tradingapp/pages/services/ThemeService.dart';
import 'package:tradingapp/pages/services/UserService.dart';
import 'package:tradingapp/pages/services/constants/constants.dart';
import 'package:tradingapp/pages/services/firebase_options.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    // name: AppConstants.appName,
    options: DefaultFirebaseOptions.currentPlatform);

  runApp(
      MultiProvider(providers: [
        ChangeNotifierProvider(create: (create)=>UserService()),
        ChangeNotifierProvider(create: (create)=>AuthService()),
        ChangeNotifierProvider(create: (create)=>ThemeService(ThemeMode.light))
      ]
      ,
      child:const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme=Provider.of<ThemeService>(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppConstants.appName,
      themeMode: theme.getTheme,
      theme: theme.getLightTheme(),
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
