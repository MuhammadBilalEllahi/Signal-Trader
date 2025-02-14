class AppConstants {
  static String appName = 'Trading App';
  static String getStarted= "Get Started";
  static final SplashText splashVal = SplashText();
  static String login= "Login";
  static String alreadyHaveAnAcount= "Already have an \naccount? ";
  static String messagePage ='Messages';
}

/// Class for Splash Screen Texts
class SplashText {
  final String secure = "Secure";
  final String anonymous = "Anonymous";
  final String private = "Private.";
}

class AppRoutes {
  static String splashScreen = '/splashScreen';
    static String authGate = '/authGate';
    static String signUp = '/authGate';
    static String signIn = '/authGate';
    static String profile = '/profile';

}


class AppAssets {
  static String splashImage = 'assets/images/Splash_Screen.jpg';
}