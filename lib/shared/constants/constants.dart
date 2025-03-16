class ApiConstants {
  // static String baseUrl = 'http://192.168.1.7:4000/';
  static String baseUrl = 'https://trading-server-production.up.railway.app/';

  // static String baseUrl = 'http://0.0.0.0:4000/';
  // static String baseUrl = 'http://localhost:4000/';
  // static String baseUrl = 'http://10.0.2.2:4000/';

  static String signals = 'signals';
  static String adminCreateSignal = 'signals/admin/create';
    static String signalsHistory = 'signals/history';
    static String signalsFavourite = 'signals/favourite';
        static String signalsFavourites = 'signals/favorites';

  static  String newsAlerts = 'news-alerts';
  static  String newsAlertsLive = 'news-alerts/live';
  static  String newsAlertsPaginated = 'news-alerts/all-paginated';
}