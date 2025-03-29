import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class CryptoPrice {
  final String symbol;
  final double price;
  final double priceChange;
  final double priceChangePercent;
  final double high24h;
  final double low24h;
  final double volume24h;

  CryptoPrice({
    required this.symbol,
    required this.price,
    required this.priceChange,
    required this.priceChangePercent,
    required this.high24h,
    required this.low24h,
    required this.volume24h,
  });

  factory CryptoPrice.fromJson(Map<String, dynamic> json) {
    return CryptoPrice(
      symbol: json['s'] as String,
      price: double.parse(json['c']),
      priceChange: double.parse(json['p']),
      priceChangePercent: double.parse(json['P']),
      high24h: double.parse(json['h']),
      low24h: double.parse(json['l']),
      volume24h: double.parse(json['v']),
    );
  }
}

class CryptoPriceProvider extends ChangeNotifier {
  static CryptoPriceProvider? _instance;
  final Map<String, CryptoPrice> _prices = {};
  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  bool _isDisposed = false;
  Timer? _pingTimer;
  Timer? _updateTimer;
  Timer? _reconnectTimer;
  DateTime? _lastUpdateTime;
  static const _pingInterval = Duration(seconds: 30);
  static const _updateInterval = Duration(seconds: 1);
  static const _reconnectDelay = Duration(seconds: 5);

  final List<String> _symbols = [
    'BTCUSDT',
    'ETHUSDT',
    'BNBUSDT',
    'ADAUSDT',
    'DOGEUSDT',
    'XRPUSDT',
    'DOTUSDT',
    'UNIUSDT'
  ];

  // Factory constructor
  factory CryptoPriceProvider() {
    _instance ??= CryptoPriceProvider._internal();
    return _instance!;
  }

  // Private constructor
  CryptoPriceProvider._internal() {
    _initWebSocket();
    _startPingTimer();
    _startUpdateTimer();
  }

  void _startPingTimer() {
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(_pingInterval, (timer) {
      if (!_isDisposed && _channel != null) {
        _channel?.sink.add('ping');
      }
    });
  }

  void _startUpdateTimer() {
    _updateTimer?.cancel();
    _updateTimer = Timer.periodic(_updateInterval, (timer) {
      if (!_isDisposed) {
        notifyListeners();
      }
    });
  }

  void _initWebSocket() {
    if (_isDisposed) return;

    // Close existing connection if any
    _closeConnection();

    // Format the streams for combined stream subscription
    final streams = _symbols.map((symbol) => 
      '${symbol.toLowerCase()}@ticker'
    ).toList();

    // Connect to combined streams with compression
    _channel = WebSocketChannel.connect(
      Uri.parse('wss://stream.binance.com:9443/stream?streams=${streams.join("/")}'),
    );

    _subscription = _channel?.stream.listen(
      (message) {
        if (_isDisposed) return;
        try {
          final data = jsonDecode(message);
          if (data is Map<String, dynamic> && data.containsKey('data')) {
            final price = CryptoPrice.fromJson(data['data']);
            _prices[price.symbol] = price;
            _lastUpdateTime = DateTime.now();
          }
        } catch (e) {
          debugPrint('Error processing message: $e');
        }
      },
      onError: (error) {
        debugPrint('WebSocket error: $error');
        _scheduleReconnect();
      },
      onDone: () {
        debugPrint('WebSocket connection closed');
        _scheduleReconnect();
      },
    );
  }

  void _closeConnection() {
    _subscription?.cancel();
    _subscription = null;
    _channel?.sink.close();
    _channel = null;
  }

  void _scheduleReconnect() {
    if (_isDisposed) return;
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(_reconnectDelay, () {
      _initWebSocket();
    });
  }

  CryptoPrice? getPriceForSymbol(String symbol) {
    return _prices[symbol];
  }

  List<CryptoPrice> getAllPrices() {
    // Sort prices by symbol to maintain consistent order
    return _prices.values.toList()
      ..sort((a, b) => a.symbol.compareTo(b.symbol));
  }

  List<String> getSymbols() {
    return _symbols;
  }

  void clearCryptoPrice() {
    // Reset all crypto price data to initial state
    _isDisposed = false;
    _prices.clear();
    _closeConnection();
    _pingTimer?.cancel();
    _updateTimer?.cancel();
    _reconnectTimer?.cancel();
    _instance = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _closeConnection();
    _pingTimer?.cancel();
    _updateTimer?.cancel();
    _reconnectTimer?.cancel();
    _instance = null;
    super.dispose();
  }
} 