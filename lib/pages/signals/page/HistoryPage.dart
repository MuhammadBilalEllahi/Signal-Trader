import 'package:flutter/material.dart';
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
  int currentPage = 1;
  bool isLoading = false;
  bool hasMore = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchHistory();
    _scrollController.addListener(_scrollListener);
  }

  Future<void> _fetchHistory({bool isLoadMore = false}) async {
    if (isLoading || !hasMore) return;

    setState(() => isLoading = true);
    final apiClient = ApiClient();

    try {
      final response = await apiClient.get(
          "${ApiConstants.signalsHistory}?page=$currentPage&pageSize=10");

      if (response != null &&
          response.containsKey("history") &&
          response["history"] is List) {
        List<Map<String, dynamic>> newHistory =
            List<Map<String, dynamic>>.from(response["history"]);

        setState(() {
          if (isLoadMore) {
            history.addAll(newHistory);
          } else {
            history = newHistory;
          }

          hasMore = response["hasMore"] ?? false;
          if (hasMore) currentPage++;
        });
      }
    } catch (e) {
      debugPrint("Error fetching history: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !isLoading) {
      _fetchHistory(isLoadMore: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
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
          child: history.isEmpty && isLoading
              ? const Center(child: CircularProgressIndicator())
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
                    controller: _scrollController,
                    itemCount: history.length + (hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == history.length) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      return SignalCard(history[index]);
                    },
                  ),
                ),
        ),
      ],
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:tradingapp/pages/signals/components/SignalCard.dart';
// import 'package:tradingapp/shared/client/ApiClient.dart';
// import 'package:tradingapp/shared/constants/Constants.dart';

// class HistoryPage extends StatefulWidget {
//   const HistoryPage({super.key});

//   @override
//   State<HistoryPage> createState() => _HistoryPageState();
// }

// class _HistoryPageState extends State<HistoryPage> {


//   @override
//   void initState() {
//     super.initState();
//     getSignalHistory();
//   }
//   Future<List<dynamic>> getSignalHistory() async {

//     final apiClient = ApiClient();
//         debugPrint("🔹 Sending GET request to: ${ApiConstants.baseUrl}${ApiConstants.signalsHistory}");

//     final response = await apiClient.get(ApiConstants.signalsHistory);
//     debugPrint("REPS $response");
//     return response is List ? response : []; // Ensure it's a list
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: TextField(
//             decoration: InputDecoration(
//               hintText: "Search history...",
//               prefixIcon: const Icon(Icons.search),
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(10),
//               ),
//             ),
//           ),
//         ),
//         Expanded(
//           child: FutureBuilder<List<dynamic>>(
//             future: getSignalHistory(), // Fetch data asynchronously
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return const Center(child: CircularProgressIndicator()); // Show loader
//               }
//               if (snapshot.hasError) {
//                 return const Center(child: Text("Error loading history")); // Handle error
//               }
//               final signals = snapshot.data ?? []; // Ensure it's a list

//               if (signals.isEmpty) {
//                 return const Center(child: Text("No history available")); // Show empty state
//               }

//               return ListView.builder(
//                 itemCount: signals.length,
//                 itemBuilder: (context, index) {
//                   return SignalCard(signals[index]); // Pass data to SignalCard
//                 },
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }
// }

