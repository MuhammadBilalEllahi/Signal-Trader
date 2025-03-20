import 'package:tradingapp/shared/client/ApiClient.dart';

class Signal {
  final String? coin;
  final String type;
  final String createdBy;
  final String direction;
  final double portfolioPercentage;
  final double entryPrice;
  final double exitPrice;
  final double gainLossPercentage;
  final DateTime createdAt;
  final DateTime expireAt;
  final bool expired;
  final DateTime timestamp;
  final bool isLive;
  final bool hasTradingAnalysis;
  final String? tradingAnalysis;
  final bool isDeleted;

  Signal({
    this.coin,
    required this.type,
    required this.createdBy,
    required this.direction,
    required this.portfolioPercentage,
    required this.entryPrice,
    required this.exitPrice,
    required this.gainLossPercentage,
    required this.createdAt,
    required this.expireAt,
    this.expired = false,
    required this.timestamp,
    this.isLive = false,
    this.hasTradingAnalysis = false,
    this.tradingAnalysis,
    this.isDeleted = false,
  });

  factory Signal.fromJson(Map<String, dynamic> json) {
    return Signal(
      coin: json['coin'],
      type: json['type'],
      createdBy: json['createdBy'],
      direction: json['direction'],
      portfolioPercentage: json['portfolioPercentage'].toDouble(),
      entryPrice: json['entryPrice'].toDouble(),
      exitPrice: json['exitPrice'].toDouble(),
      gainLossPercentage: json['gainLossPercentage'].toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
      expireAt: DateTime.parse(json['expireAt']),
      expired: json['expired'] ?? false,
      timestamp: DateTime.parse(json['timestamp']),
      isLive: json['isLive'] ?? false,
      hasTradingAnalysis: json['hasTradingAnalysis'] ?? false,
      tradingAnalysis: json['tradingAnalysis'],
      isDeleted: json['isDeleted'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'coin': coin,
      'type': type,
      'createdBy': createdBy,
      'direction': direction,
      'portfolioPercentage': portfolioPercentage,
      'entryPrice': entryPrice,
      'exitPrice': exitPrice,
      'gainLossPercentage': gainLossPercentage,
      'createdAt': createdAt.toIso8601String(),
      'expireAt': expireAt.toIso8601String(),
      'expired': expired,
      'timestamp': timestamp.toIso8601String(),
      'isLive': isLive,
      'hasTradingAnalysis': hasTradingAnalysis,
      'tradingAnalysis': tradingAnalysis,
      'isDeleted': isDeleted,
    };
  }
}

class SignalService {
  static final ApiClient _apiClient = ApiClient();

  static Future<List<Signal>> getSignals() async {
    final response = await _apiClient.get('signals');
    if (response != null && response is List) {
      return response.map((json) => Signal.fromJson(json)).toList();
    }
    return [];
  }

  static Future<List<Signal>> getSignalsWithFilters(String filter) async {
    final response = await _apiClient.get('signals/filters/$filter');
    if (response != null && response is List) {
      return response.map((json) => Signal.fromJson(json)).toList();
    }
    return [];
  }
}