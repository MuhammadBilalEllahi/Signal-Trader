import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:tradingapp/pages/signals/components/ShimmerSignalCard.dart';
import 'package:tradingapp/pages/signals/components/SignalCard.dart';
import 'package:tradingapp/pages/signals/providers/signals_provider.dart';
import 'package:tradingapp/shared/client/ApiClient.dart';
import 'package:tradingapp/shared/constants/Constants.dart';

class CurrentSignalsPage extends StatefulWidget {
  const CurrentSignalsPage({super.key});

  @override
  _CurrentSignalsPageState createState() => _CurrentSignalsPageState();
}

class _CurrentSignalsPageState extends State<CurrentSignalsPage> {
  bool isVertical = false;
  final PageController _pageController = PageController();
  late IO.Socket socket;

  // Filter state variables
  String selectedType = 'all';
  String selectedCoin = '';
  String selectedDirection = 'all';
  bool showFilterDialog = false;

  // Applied filter state variables
  String appliedType = 'all';
  String appliedCoin = '';
  String appliedDirection = 'all';

  @override
  void initState() {
    super.initState();
    _loadViewPreference();
    _initializeData();
    _connectSocket();
  }

  Future<void> _initializeData() async {
    final provider = Provider.of<SignalsProvider>(context, listen: false);
    await provider.initializeSignals();
  }

  @override
  void dispose() {
    _pageController.dispose();
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

      // Also reset applied filters
      appliedType = 'all';
      appliedCoin = '';
      appliedDirection = 'all';
    });
  }

  void _applyFilters() {
    setState(() {
      appliedType = selectedType;
      appliedCoin = selectedCoin;
      appliedDirection = selectedDirection;
    });
  }

  List<Map<String, dynamic>> getFilteredSignals(List<Map<String, dynamic>> signals) {
    return signals.where((signal) {
      bool typeMatch = appliedType == 'all' || signal['type'].toString().toLowerCase() == appliedType.toLowerCase();
      bool coinMatch = appliedCoin.isEmpty || signal['coin'].toString().toLowerCase().contains(appliedCoin.toLowerCase());
      bool directionMatch = appliedDirection == 'all' || signal['direction'].toString().toLowerCase() == appliedDirection;
     
      return typeMatch && coinMatch && directionMatch;
    }).toList();
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
        Provider.of<SignalsProvider>(context, listen: false).addNewSignal(data);
      } else {
        debugPrint("Invalid signal data received: $data");
      }
    });

    socket.onDisconnect((_) => debugPrint('Disconnected from WebSocket'));
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: const Color(0xFF1C1C1C),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Filter Signals',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF2C2C2C),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF3C3C3C)),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedType,
                          isExpanded: true,
                          dropdownColor: const Color(0xFF2C2C2C),
                          style: const TextStyle(color: Colors.white),
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
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Search by Coin',
                        labelStyle: const TextStyle(color: Colors.grey),
                        filled: true,
                        fillColor: const Color(0xFF2C2C2C),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFF3C3C3C)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFF3C3C3C)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFFFFD700)),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() => selectedCoin = value);
                      },
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF2C2C2C),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF3C3C3C)),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedDirection,
                          isExpanded: true,
                          dropdownColor: const Color(0xFF2C2C2C),
                          style: const TextStyle(color: Colors.white),
                          items: const [
                            DropdownMenuItem(value: 'all', child: Text('All Directions')),
                            DropdownMenuItem(value: 'long', child: Text('Long')),
                            DropdownMenuItem(value: 'short', child: Text('Short')),
                          ],
                          onChanged: (value) {
                            setState(() => selectedDirection = value!);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            _resetFilters();
                            Navigator.pop(context);
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.grey,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          child: const Text('Reset'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            _applyFilters();
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFD700),
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          child: const Text('Apply'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
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

  bool get isDark {
    return Theme.of(context).brightness == Brightness.dark;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SignalsProvider>(
      builder: (context, signalsProvider, child) {
        final filteredSignals = getFilteredSignals(signalsProvider.signals);
        final currentIndex = signalsProvider.currentIndex;
        
        return RefreshIndicator(
          onRefresh: () => signalsProvider.fetchSignals(refresh: true),
          child: Column(
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
                              !signalsProvider.isLoading && signalsProvider.hasMore) {
                            signalsProvider.fetchSignals();
                          }
                          return false;
                        },
                        child: ListView.builder(
                          itemCount: filteredSignals.length + (signalsProvider.hasMore ? 1 : 0),
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
                    : PageView.builder(
                        controller: _pageController,
                        itemCount: signalsProvider.isLoading ? filteredSignals.length + 1 : filteredSignals.length,
                        onPageChanged: (index) {
                          final provider = Provider.of<SignalsProvider>(context, listen: false);
                          provider.setCurrentIndex(index);
                          if (index == filteredSignals.length - 1 && signalsProvider.hasMore) {
                            provider.fetchSignals();
                          }
                        },
                        itemBuilder: (context, index) {
                          if (index == filteredSignals.length && signalsProvider.isLoading) {
                            return ShimmerSignalCard(100);
                          }
                          return SignalCard(filteredSignals[index], showAnalysis: true);
                        },
                      ),
              ),
              if (!isVertical) ...[
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        final provider = Provider.of<SignalsProvider>(context, listen: false);
                        if (currentIndex > 0) {
                          provider.setCurrentIndex(currentIndex - 1);
                          _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                        } else if (!signalsProvider.isLoading && signalsProvider.hasMore) {
                          provider.fetchSignals();
                        }
                      },
                      child: const Text("Prev"),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: _getVisibleIndices(currentIndex, filteredSignals.length)
                          .map((index) =>  TextButton(
                                  onPressed: () {
                                    final provider = Provider.of<SignalsProvider>(context, listen: false);
                                    provider.setCurrentIndex(index);
                                    _pageController.jumpToPage(index);
                                  },
                                  style: TextButton.styleFrom(
                                    backgroundColor: currentIndex == index ? Colors.yellow : Colors.transparent,
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    minimumSize: const Size(0, 0),
                                  ),
                                  child: Text(
                                    '${index + 1}',
                                    style: TextStyle(
                                      color: currentIndex == index ? isDark  ? Colors.black : Colors.white : Theme.of(context).colorScheme.onSurface,
                                    ),
                                  ),
                              ))
                          .toList(),
                    ),
                    TextButton(
                      onPressed: () {
                        final provider = Provider.of<SignalsProvider>(context, listen: false);
                        if (currentIndex < filteredSignals.length - 1) {
                          provider.setCurrentIndex(currentIndex + 1);
                          _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                        } else if (!signalsProvider.isLoading && signalsProvider.hasMore) {
                          provider.fetchSignals();
                        }
                      },
                      child: const Text("Next"),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ],
          ),
        );
      },
    );
  }
}
