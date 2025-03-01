import 'package:flutter/material.dart';
import 'package:tradingapp/shared/client/ApiClient.dart';
import 'package:tradingapp/shared/constants/Constants.dart';

class SignalCard extends StatefulWidget {
  final Map<String, dynamic> signal;

  const SignalCard(this.signal, {super.key});

  @override
  _SignalCardState createState() => _SignalCardState();
}

class _SignalCardState extends State<SignalCard> {
  bool isFavorite = false; // Local state to track favorite status

  @override
  void initState() {
    super.initState();
    isFavorite = widget.signal['isFavorite'] ?? false; // Initialize state
  }

  Future<void> toggleFavorite() async {
    final apiClient = ApiClient();
    final signalId = widget.signal["_id"];

    final url = "${ApiConstants.baseUrl}signals/favorite/$signalId";
    debugPrint("🔹 Toggling favorite: $url");

    try {
      final response = await apiClient.post(url, {}); // Send POST request
      debugPrint("✅ Favorite toggled: $response");

      setState(() {
        isFavorite = !isFavorite; // Toggle favorite status
      });
    } catch (e) {
      debugPrint("❌ Error toggling favorite: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        color: Theme.of(context).cardColor,
        elevation: 10,
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.signal["coin"],
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      Text("Created: ${widget.signal["createdAt"]}",
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 12)),
                      if (widget.signal['expired'] == true)
                        const Text('Expired', style: TextStyle(color: Colors.red))
                      else
                        Text("Expires: ${widget.signal["expireAt"]}",
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 11)),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : Colors.grey,
                        ),
                        onPressed: toggleFavorite, // Call toggle function
                      ),
                      TextButton(
                        onPressed: () {},
                        child: Text("${widget.signal['direction']}"),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Entry: ${widget.signal["entryPrice"]}",
                      style: const TextStyle(color: Colors.green, fontSize: 19)),
                  Text("Exit: ${widget.signal["exitPrice"]}",
                      style: const TextStyle(color: Colors.red, fontSize: 19)),
                ],
              ),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Gain: ${widget.signal["gainLossPercentage"]}%",
                      style: const TextStyle(color: Colors.green, fontSize: 19)),
                  Text("Portfolio: ${widget.signal["portfolioPercentage"]}%",
                      style: const TextStyle(color: Colors.red, fontSize: 19)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:tradingapp/shared/client/ApiClient.dart';
// import 'package:tradingapp/shared/constants/Constants.dart';

// class SignalCard extends StatelessWidget {
//   final Map<String, dynamic> signal;

//   const SignalCard(this.signal, {super.key});

//   Future<List<dynamic>> toggleFavorite() async {
//     final apiClient = ApiClient();
//     debugPrint("🔹 Sending GET request to: ${ApiConstants.baseUrl}${ApiConstants.signalsFavourite}");

//     try {
//       final response = await apiClient.get(ApiConstants.signalsFavourite);
//       debugPrint("✅ Response received: $response");
//       return response is List ? response : [];
//     } catch (e) {
//       debugPrint("❌ Error in GET request: $e");
//       return [];
//     }
//   }
//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       width: MediaQuery.of(context).size.width,
//       child: Card(
//         margin: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//         color: Theme.of(context).cardColor,
//         elevation: 50,
//         child: Padding(
//           padding: const EdgeInsets.all(15),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(signal["coin"],
//                           style: TextStyle(
//                               fontSize: 20, fontWeight: FontWeight.bold)),
//                       Text("Created: ${signal["createdAt"]}",
//                           style: TextStyle(color: Colors.grey, fontSize: 12)),
//                          if(signal['expired'] == true) Text('expired') else Text("Created: ${signal["expireAt"]}",
//                           style: TextStyle(color: Colors.grey, fontSize: 11)),
//                     ],
//                   ),
//                   TextButton(
//                     onPressed: () {},
//                     child: Text("${signal['direction']}"),
//                   )
//                 ],
//               ),
//               SizedBox(height: 10),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text("Entry: ${signal["entryPrice"]}",
//                       style: TextStyle(color: Colors.green, fontSize: 19)),
//                   Text("Exit: ${signal["exitPrice"]}",
//                       style: TextStyle(color: Colors.red, fontSize: 19)),
//                 ],
//               ),
//               SizedBox(height: 5),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text("Gain: ${signal["gainLossPercentage"]}%",
//                       style: TextStyle(color: Colors.green, fontSize: 19)),
//                   // Text("Loss: ${signal["loss"]}%",
//                   //     style: TextStyle(color: Colors.red, fontSize: 19)),
//                   Text("portfolio: ${signal["portfolioPercentage"]}%",
//                       style: TextStyle(color: Colors.red, fontSize: 19)),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
      
//     );
//   }
// }
