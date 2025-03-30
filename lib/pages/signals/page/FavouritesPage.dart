import 'package:flutter/material.dart';
import 'package:tradingapp/pages/signals/components/ShimmerSignalCard.dart';
import 'package:tradingapp/pages/signals/components/SignalCard.dart';
import 'package:tradingapp/shared/client/ApiClient.dart';
import 'package:tradingapp/shared/constants/Constants.dart';

class FavouritesPage extends StatefulWidget {
  const FavouritesPage({super.key});

  @override
  State<FavouritesPage> createState() => _FavouritesPageState();
}

class _FavouritesPageState extends State<FavouritesPage> {
  List<Map<String, dynamic>> favSignals = [];
  int currentPage = 1;
  bool isLoading = false;
  bool hasMore = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchFavouriteSignals();
    _scrollController.addListener(_scrollListener);
  }

  Future<void> _fetchFavouriteSignals({bool isLoadMore = false}) async {
    if (isLoading || !hasMore) return;

    setState(() => isLoading = true);
    final apiClient = ApiClient();

    try {
      final response = await apiClient.get(
          "${ApiConstants.signalsFavourites}?page=$currentPage&pageSize=10");

print("Response Fav $response");
      if (response != null &&
          response.containsKey("favorites") &&
          response["favorites"] is List) {
        List<Map<String, dynamic>> newFavorites =
            List<Map<String, dynamic>>.from(response["favorites"]);

        setState(() {
          if (isLoadMore) {
            favSignals.addAll(newFavorites);
          } else {
            favSignals = newFavorites;
          }

          hasMore = response["hasMore"] ?? false;
          if (hasMore) currentPage++;
        });
      }
    } catch (e) {
      //debugPrint("Error fetching favourite signals: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !isLoading) {
      _fetchFavouriteSignals(isLoadMore: true);
    }
  }

  Future<void> _refreshFavourites() async {
    setState(() {
      currentPage = 1;
      hasMore = true;
    });
    await _fetchFavouriteSignals();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refreshFavourites,
      child: Column(
        children: [
          Expanded(
            child: favSignals.isEmpty && isLoading
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
                        _fetchFavouriteSignals(isLoadMore: true);
                      }
                      return false;
                    },
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      controller: _scrollController,
                      itemCount: favSignals.length + (hasMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == favSignals.length) {
                          return Column(
                            children: [
                              ShimmerSignalCard(200),
                              ShimmerSignalCard(200),
                              ShimmerSignalCard(200),
                            ],
                          );
                        }
                        return SignalCard(favSignals[index]);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:tradingapp/pages/signals/components/SignalCard.dart';
// import 'package:tradingapp/shared/client/ApiClient.dart';
// import 'package:tradingapp/shared/constants/Constants.dart';

// class FavouritesPage extends StatefulWidget {
//   const FavouritesPage({super.key});

//   @override
//   State<FavouritesPage> createState() => _FavouritesPageState();
// }

// class _FavouritesPageState extends State<FavouritesPage> {
//   late Future<List<dynamic>> _favSignalsFuture;

//   @override
//   void initState() {
//     super.initState();
//     _favSignalsFuture = getSignalHistory();
//   }

//   Future<List<dynamic>> getSignalHistory() async {
//     final apiClient = ApiClient();
//     //debugPrint("🔹 Sending GET request to: ${ApiConstants.baseUrl}${ApiConstants.signalsFavourites}");

//     try {
//       final response = await apiClient.get(ApiConstants.signalsFavourites);
//       //debugPrint("✅ Response received: $response");
//       return response is List ? response : [];
//     } catch (e) {
//       //debugPrint("❌ Error in GET request: $e");
//       return [];
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<List<dynamic>>(
//       future: _favSignalsFuture,
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator()); // Show loading
//         }
//         if (snapshot.hasError) {
//           return const Center(child: Text("Error loading favourites"));
//         }
//         final favSignals = snapshot.data ?? [];

//         return favSignals.isEmpty
//             ? const Center(child: Text("No favourites available"))
//             : ListView.builder(
//                 itemCount: favSignals.length,
//                 itemBuilder: (context, index) => SignalCard(favSignals[index]),
//               );
//       },
//     );
//   }
// }



// // import 'package:flutter/material.dart';
// // import 'package:tradingapp/pages/signals/components/SignalCard.dart';
// // import 'package:tradingapp/shared/client/ApiClient.dart';
// // import 'package:tradingapp/shared/constants/Constants.dart';

// // class FavouritesPage extends StatefulWidget {
// //   const FavouritesPage({super.key});

// //   @override
// //   State<FavouritesPage> createState() => _FavouritesPageState();
// // }

// // class _FavouritesPageState extends State<FavouritesPage> {

// //   @override
// //   void initState() {
// //     super.initState();
// //     getSignalHistory();
// //   }
// //   Future<List<dynamic>> getSignalHistory() async {

// //     final apiClient = ApiClient();
// //         //debugPrint("🔹 Sending GET request to: ${ApiConstants.baseUrl}${ApiConstants.signalsFavourites}");

// //     final response = await apiClient.get(ApiConstants.signalsFavourites);
// //     //debugPrint("REPS $response");
// //     return response is List ? response : []; // Ensure it's a list
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     List<Map<String, dynamic>> favSignals = getSignalHistory();
// //     return ListView.builder(
// //       itemCount: favSignals.length,
// //       itemBuilder: (context, index) {
// //         return SignalCard(favSignals[index]);
// //       },
// //     );
// //   }
// // }

