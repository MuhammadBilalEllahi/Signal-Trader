import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:tradingapp/pages/signals/components/ShimmerSignalCard.dart';
import 'package:tradingapp/pages/signals/components/SignalCard.dart';
import 'package:tradingapp/shared/client/ApiClient.dart';
import 'package:tradingapp/shared/constants/Constants.dart';

class CurrentSignalsPage extends StatefulWidget {
  const CurrentSignalsPage({super.key});

  @override
  _CurrentSignalsPageState createState() => _CurrentSignalsPageState();
}

class _CurrentSignalsPageState extends State<CurrentSignalsPage> {
  bool isVertical = false;
  int currentIndex = 0;
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> signals = [];
  late IO.Socket socket;

  int currentPage = 1;
  bool isLoading = false;
  bool hasMore = true;

  @override
  void initState() {
    super.initState();
    _loadViewPreference();
    _fetchPaginatedSignals();
    _connectSocket();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadViewPreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isVertical = prefs.getBool('isVertical') ?? false;
    });
  }

  Future<void> _saveViewPreference(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isVertical', value);
  }

  Future<void> _fetchPaginatedSignals({bool isLoadMore = false}) async {
    if (isLoading || !hasMore) return;

    final apiClient = ApiClient();
    setState(() => isLoading = true);

    try {
      final response = await apiClient.get("signals/paginated?pageId=$currentPage&pageSize=5");
      print("response $response");

      if (response != null && response.containsKey("signals")) {
        List<Map<String, dynamic>> newSignals = List<Map<String, dynamic>>.from(response["signals"]);

        setState(() {
          if (isLoadMore) {
            signals.addAll(newSignals);
          } else {
            signals = newSignals;
          }

          hasMore = newSignals.length == 5;
          if (hasMore) currentPage++;
        });
      } else {
        debugPrint("Error fetching signals: ${response.body}");
      }
    } catch (e) {
      debugPrint("Exception fetching signals: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _connectSocket() async {
    String? token = await FirebaseAuth.instance.currentUser?.getIdToken();
    socket = IO.io(
      "${ApiConstants.baseUrl}${ApiConstants.signals}",
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setQuery({'Authorization': 'Bearer $token'})
          .build(),
    );

    socket.onConnect((_) {
      debugPrint('Connected to WebSocket');
      socket.emit('subscribeToSignals');
    });

    socket.on('new-signal', (data) {
      debugPrint("SIGNAL DATA $data");
      if (data != null && data is Map<String, dynamic>) {
        setState(() {
          signals.insert(0, data);
        });
      } else {
        debugPrint("Invalid signal data received: $data");
      }
    });

    socket.onDisconnect((_) => debugPrint('Disconnected from WebSocket'));
  }

  void _scrollToIndex(int index) {
    double offset = index * MediaQuery.of(context).size.width;
    _scrollController.animateTo(
      offset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 50 &&
        hasMore &&
        !isLoading) {
      _fetchPaginatedSignals(isLoadMore: true);
    }
  }

  void _handleNext() {
    if (currentIndex < signals.length - 1) {
      setState(() {
        currentIndex++;
        _scrollToIndex(currentIndex);
      });
    }

    if (currentIndex == signals.length - 1 && hasMore && !isLoading) {
      _fetchPaginatedSignals(isLoadMore: true);
    }
  }

  void _handlePrev() {
    if (currentIndex > 0) {
      setState(() {
        currentIndex--;
        _scrollToIndex(currentIndex);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              icon: Icon(isVertical ? Icons.view_array : Icons.calendar_view_day_rounded),
              onPressed: () {
                setState(() {
                  isVertical = !isVertical;
                  _saveViewPreference(isVertical);
                });
              },
            ),
          ],
        ),
        Expanded(
          child: isVertical
              ? NotificationListener<ScrollNotification>(
                  onNotification: (scrollNotification) {
                    if (scrollNotification.metrics.pixels == scrollNotification.metrics.maxScrollExtent &&
                        !isLoading) {
                      _fetchPaginatedSignals(isLoadMore: true);
                    }
                    return false;
                  },
                  child: ListView.builder(
                    itemCount: signals.length + (hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == signals.length) {
                        return  Column(
                          children: [ShimmerSignalCard(100),ShimmerSignalCard(100),ShimmerSignalCard(100)],
                          
                        );
                      }
                      return SignalCard(signals[index]);
                    },
                  ),
                )
              : NotificationListener<ScrollNotification>(
                  onNotification: (scrollNotification) {
                    if (scrollNotification.metrics.pixels >= scrollNotification.metrics.maxScrollExtent - 50 &&
                        hasMore &&
                        !isLoading) {
                      _fetchPaginatedSignals(isLoadMore: true);
                    }
                    return false;
                  },
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    controller: _scrollController,
                    child: Row(
  children: [
    ...signals.map((signal) => SignalCard(signal)),
    if (isLoading) ...[
      ShimmerSignalCard(500),
      ShimmerSignalCard(500),
      ShimmerSignalCard(500),
    ],
  ],
),

                  ),
                ),
        ),
        if (!isVertical)
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: _handlePrev,
                child: const Text("Prev"),
              ),
              TextButton(
                onPressed: _handleNext,
                child: const Text("Next"),
              ),
            ],
          ),
        if (!isVertical)
          const SizedBox(height: 20),
      ],
    );
  }
}
