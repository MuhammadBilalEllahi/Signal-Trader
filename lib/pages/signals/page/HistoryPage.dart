import 'package:flutter/material.dart';
import 'package:tradingapp/pages/signals/components/ShimmerSignalCard.dart'; 
import 'package:tradingapp/pages/signals/components/SignalCard.dart';
import 'package:tradingapp/shared/client/ApiClient.dart';
import 'package:tradingapp/shared/constants/Constants.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<Map<String, dynamic>> history = [];
  List<Map<String, dynamic>> filteredHistory = []; // Stores search results
  int currentPage = 1;
  bool isLoading = false;
  bool hasMore = true;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchHistory();
    _scrollController.addListener(_scrollListener);
    _searchController.addListener(_filterHistory); // Listen for search input
  }

  Future<void> _fetchHistory({bool isLoadMore = false}) async {
    if (isLoading || !hasMore) return;

    setState(() => isLoading = true);
    final apiClient = ApiClient();

    try {
      final response = await apiClient.get(
          "${ApiConstants.signalsHistory}?pageId=$currentPage&pageSize=10");

      if (response != null &&
          response.containsKey("history") &&
          response["history"] is List) {
        List<Map<String, dynamic>> newHistory =
            List<Map<String, dynamic>>.from(response["history"]);

        debugPrint("\n\nREsponse $response");
        setState(() {
          if (isLoadMore) {
            if (newHistory.isNotEmpty) {
              history.addAll(newHistory);
              currentPage++; // Increase only if new data is received
            } else {
              hasMore = false; // Stop further requests
            }
          } else {
            history = newHistory;
            currentPage = 2; // Reset to second page when fetching fresh data
          }

          hasMore = response["hasMore"] ?? false;
          _filterHistory();
        });
      } else {
        setState(() => hasMore = false); // No more data
      }
    } catch (e) {
      debugPrint("Error fetching history: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _filterHistory() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      filteredHistory = history.where((signal) {
        return signal["coin"].toLowerCase().contains(query);
      }).toList();
    });
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !isLoading) {
      _fetchHistory(isLoadMore: true);
    }
  }

  Future<void> _refreshHistory() async {
    setState(() {
      currentPage = 1;
      hasMore = true;
    });
    await _fetchHistory();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refreshHistory,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search history...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          Expanded(
            child: filteredHistory.isEmpty && isLoading
                ? Column(
                    children: [
                      ShimmerSignalCard(120),
                      ShimmerSignalCard(120),
                      ShimmerSignalCard(120),
                    ],
                  )
                : NotificationListener<ScrollNotification>(
                    onNotification: (scrollNotification) {
                      if (scrollNotification.metrics.pixels ==
                              scrollNotification.metrics.maxScrollExtent &&
                          !isLoading) {
                        _fetchHistory(isLoadMore: true);
                      }
                      return false;
                    },
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      controller: _scrollController,
                      itemCount: filteredHistory.length + (hasMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == filteredHistory.length) {
                          return Column(
                            children: [
                              ShimmerSignalCard(120),
                              ShimmerSignalCard(120),
                              ShimmerSignalCard(120),
                            ],
                          );
                        }
                        return SignalCard(filteredHistory[index]);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}