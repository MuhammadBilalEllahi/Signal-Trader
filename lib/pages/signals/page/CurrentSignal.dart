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

  // Filter state variables
  String selectedType = 'all';
  String selectedCoin = '';
  String selectedDirection = 'all';
  RangeValues entryPriceRange = const RangeValues(0, 100000);
  RangeValues exitPriceRange = const RangeValues(0, 100000);
  bool showFilterDialog = false;

  // Applied filter state variables
  String appliedType = 'all';
  String appliedCoin = '';
  String appliedDirection = 'all';
  RangeValues appliedEntryPriceRange = const RangeValues(0, 100000);
  RangeValues appliedExitPriceRange = const RangeValues(0, 100000);

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

  void _resetFilters() {
    setState(() {
      selectedType = 'all';
      selectedCoin = '';
      selectedDirection = 'all';
      selectedType = 'all';
      entryPriceRange = const RangeValues(0, 100000);
      exitPriceRange = const RangeValues(0, 100000);
      
      // Also reset applied filters
      appliedType = 'all';
      appliedCoin = '';
      appliedDirection = 'all';
      appliedEntryPriceRange = const RangeValues(0, 100000);
      appliedExitPriceRange = const RangeValues(0, 100000);
    });
  }

  void _applyFilters() {
    setState(() {
      appliedType = selectedType;
      appliedCoin = selectedCoin;
      appliedDirection = selectedDirection;
      appliedEntryPriceRange = entryPriceRange;
      appliedExitPriceRange = exitPriceRange;
    });
  }

  List<Map<String, dynamic>> getFilteredSignals() {
    return signals.where((signal) {
      bool typeMatch = appliedType == 'all' || signal['type'] == appliedType;
      bool coinMatch = appliedCoin.isEmpty || signal['coin'].toString().toLowerCase().contains(appliedCoin.toLowerCase());
      bool directionMatch = appliedDirection == 'all' || signal['direction'].toString().toLowerCase() == appliedDirection;
      bool entryPriceMatch = signal['entryPrice'] >= appliedEntryPriceRange.start && signal['entryPrice'] <= appliedEntryPriceRange.end;
      bool exitPriceMatch = signal['exitPrice'] >= appliedExitPriceRange.start && signal['exitPrice'] <= appliedExitPriceRange.end;
      
      return typeMatch && coinMatch && directionMatch && entryPriceMatch && exitPriceMatch;
    }).toList();
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
    double offset = index * MediaQuery.of(context).size.width ;
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
    
    // Update current index based on scroll position
    setState(() {
      currentIndex = (_scrollController.position.pixels / MediaQuery.of(context).size.width).round();
    });
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

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              
              title: const Text('Filter Signals'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    DropdownButton<String>(
                      value: selectedType,
                      isExpanded: true,
                      items: const [
                        DropdownMenuItem(value: 'all', child: Text('All Types')),
                        DropdownMenuItem(value: 'gold', child: Text('Gold')),
                        DropdownMenuItem(value: 'stocks', child: Text('Stocks')),
                        DropdownMenuItem(value: 'crypto', child: Text('Crypto')),
                      ],
                      onChanged: (value) {
                        setState(() => selectedType = value!);
                      },
                    ),
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Search by Coin',
                      ),
                      onChanged: (value) {
                        setState(() => selectedCoin = value);
                      },
                    ),
                    DropdownButton<String>(
                      value: selectedDirection,
                      isExpanded: true,
                      items: const [
                        DropdownMenuItem(value: 'all', child: Text('All Directions')),
                        DropdownMenuItem(value: 'long', child: Text('Long')),
                        DropdownMenuItem(value: 'short', child: Text('Short')),
                      ],
                      onChanged: (value) {
                        setState(() => selectedDirection = value!);
                      },
                    ),
                    const Text('Entry Price Range'),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Entry Price Range', style: TextStyle(fontWeight: FontWeight.w500)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                decoration: const InputDecoration(
                                  labelText: 'Min Price',
                                  prefixText: '\$',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  final minPrice = double.tryParse(value) ?? 0;
                                  setState(() {
                                    entryPriceRange = RangeValues(
                                      minPrice,
                                      entryPriceRange.end,
                                    );
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextField(
                                decoration: const InputDecoration(
                                  labelText: 'Max Price',
                                  prefixText: '\$',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  final maxPrice = double.tryParse(value) ?? 100000;
                                  setState(() {
                                    entryPriceRange = RangeValues(
                                      entryPriceRange.start,
                                      maxPrice,
                                    );
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text('Exit Price Range', style: TextStyle(fontWeight: FontWeight.w500)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                decoration: const InputDecoration(
                                  labelText: 'Min Price',
                                  prefixText: '\$',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  final minPrice = double.tryParse(value) ?? 0;
                                  setState(() {
                                    exitPriceRange = RangeValues(
                                      minPrice,
                                      exitPriceRange.end,
                                    );
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextField(
                                decoration: const InputDecoration(
                                  labelText: 'Max Price',
                                  prefixText: '\$',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  final maxPrice = double.tryParse(value) ?? 100000;
                                  setState(() {
                                    exitPriceRange = RangeValues(
                                      exitPriceRange.start,
                                      maxPrice,
                                    );
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    _resetFilters();
                    Navigator.pop(context);
                  },
                  child: const Text('Reset'),
                ),
                TextButton(
                  onPressed: () {
                    _applyFilters();
                    Navigator.pop(context);
                  },
                  child: const Text('Apply'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  List<int> _getVisibleIndices(int currentIndex, int totalLength) {
    int start = currentIndex - 2;
    int end = currentIndex + 2;
    
    if (start < 0) {
      start = 0;
      end = start + 4;
    }
    
    if (end >= totalLength) {
      end = totalLength - 1;
      start = end - 4;
    }
    
    if (start < 0) start = 0;
    
    return List.generate(end - start + 1, (index) => start + index);
  }

  @override
  Widget build(BuildContext context) {
    final filteredSignals = getFilteredSignals();
    
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 7),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: _showFilterDialog,
              ),
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
                    itemCount: filteredSignals.length + (hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == filteredSignals.length) {
                        return Column(
                          children: [ShimmerSignalCard(100), ShimmerSignalCard(100), ShimmerSignalCard(100)],
                        );
                      }
                      return SignalCard(filteredSignals[index]);
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
                        ...filteredSignals.map((signal) => SignalCard(signal, showAnalysis: true)),
                        if (isLoading) ...[
                          ShimmerSignalCard(600),
                          ShimmerSignalCard(600),
                          ShimmerSignalCard(600),
                        ],
                      ],
                    ),
                  ),
                ),
        ),
        if (!isVertical) ...[
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: _handlePrev,
                child: const Text("Prev"),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: _getVisibleIndices(currentIndex, filteredSignals.length)
                    .map((index) =>  TextButton(
                            onPressed: () => _scrollToIndex(index),
                            style: TextButton.styleFrom(
                              backgroundColor: currentIndex == index ? Colors.yellow : Colors.transparent,
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              minimumSize: const Size(0, 0),
                            ),
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(
                                color: currentIndex == index ?   Colors.black: Colors.white,
                              ),
                            ),
                        
                        ))
                    .toList(),
              ),
              TextButton(
                onPressed: _handleNext,
                child: const Text("Next"),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ],
    );
  }
}
