import 'package:flutter/material.dart';
import 'package:tradingapp/shared/client/ApiClient.dart';
import 'package:tradingapp/shared/constants/Constants.dart';
import 'package:tradingapp/pages/signals/components/SignalDetailedPage.dart';

class SignalCard extends StatefulWidget {
  final Map<String, dynamic> signal;
  final bool showAnalysis;

  const SignalCard(this.signal, {this.showAnalysis = false, super.key});

  @override
  _SignalCardState createState() => _SignalCardState();
}

class _SignalCardState extends State<SignalCard> {
  bool isFavorite = false; // Local state to track favorite status
  bool showFullAnalysis = false;

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
      width: MediaQuery.of(context).size.width * 0.95,
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
                  Row(
                    children: [
                      Text(widget.signal["coin"],
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      if(widget.signal["type"] != "gold") Container(
                        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                        margin: const EdgeInsets.only(left: 8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.yellow.shade700, Colors.yellow.shade100],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            "GOLD",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ),
                      if(widget.signal["type"] == "crypto") Container(
                        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                        margin: const EdgeInsets.only(left: 8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.grey.shade700, Colors.grey.shade500],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            "CRYPTO",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ),
                      if(widget.signal["type"] == "stocks") Container(
                        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                        margin: const EdgeInsets.only(left: 8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.black87, Colors.black12],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            "STOCKS", 
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ),
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
                        style: ButtonStyle(
                            backgroundColor: WidgetStatePropertyAll(widget
                                        .signal['direction']
                                        .toString()
                                        .toLowerCase() ==
                                    'long'
                                ? Colors.green
                                : Colors.red),
                            shape: WidgetStatePropertyAll(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    side: BorderSide(
                                        color: widget.signal['direction']
                                                    .toString()
                                                    .toLowerCase() ==
                                                'long'
                                            ? Colors.green.shade800
                                            : Colors.red.shade800,
                                        width: 2)))),
                        child: Text("${widget.signal['direction']}",
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
              Divider(),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.grey[900]!,
                      Colors.grey[850]!,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.grey[800]!,
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.access_time, 
                                    size: 16,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "Date/Time",
                                    style: TextStyle(
                                      color: Colors.grey[400],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "${widget.signal["createdFormatted"]}",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: 40,
                          width: 1,
                          color: Colors.grey[700],
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Icon(Icons.account_balance_wallet,
                                    size: 16,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "Portfolio %",
                                    style: TextStyle(
                                      color: Colors.grey[400],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "${widget.signal["portfolioPercentage"]}%",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      height: 1,
                      color: Colors.grey[700],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.call_made,
                                    size: 16,
                                    color: Colors.green[400],
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "Entry Price",
                                    style: TextStyle(
                                      color: Colors.grey[400],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "\$${widget.signal["entryPrice"]}",
                                style: TextStyle(
                                  color: Colors.green[400],
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: 40,
                          width: 1,
                          color: Colors.grey[700],
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Icon(Icons.call_received,
                                    size: 16,
                                    color: Colors.red[400],
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "Exit Price",
                                    style: TextStyle(
                                      color: Colors.grey[400],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "\$${widget.signal["exitPrice"]}",
                                style: TextStyle(
                                  color: Colors.red[400],
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // if (widget.showAnalysis == true) ...[
              //   const SizedBox(height: 10),
              //   Text("Analysis: ${'widget.signal["analysis"]'}")
              // ],
              if(widget.showAnalysis==true) Container(
                margin: const EdgeInsets.only(top: 16),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.grey[900]!,
                      Colors.grey[850]!,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.grey[800]!,
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.amber[400]!.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.analytics_outlined,
                            color: Colors.amber[400],
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Analysis',
                          style: TextStyle(
                            color: Colors.amber[400],
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final text = widget.signal["analysis"] ?? "No analysis available for this signal.";
                        final textSpan = TextSpan(
                          text: text,
                          style: TextStyle(
                            color: Colors.grey[300],
                            fontSize: 13,
                            height: 1.5,
                          ),
                        );
                        final textPainter = TextPainter(
                          text: textSpan,
                          textDirection: TextDirection.ltr,
                          maxLines: showFullAnalysis ? null : 6,
                        );
                        textPainter.layout(maxWidth: constraints.maxWidth);
                        
                        final exceededMaxLines = textPainter.didExceedMaxLines;
                        
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              text,
                              style: TextStyle(
                                color: Colors.grey[300],
                                fontSize: 13,
                                height: 1.5,
                              ),
                              maxLines: showFullAnalysis ? null : 6,
                              overflow: TextOverflow.fade,
                            ),
                            if (exceededMaxLines)
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SignalDetailedPage(signal: widget.signal),
                                    ),
                                  );
                                },
                                child: Text(
                                  showFullAnalysis ? 'Show less' : 'Show more...',
                                  style: TextStyle(
                                    color: Colors.amber[400],
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}



                  // if (widget.signal['expired'] == true)
                  //   const Text('Expired', style: TextStyle(color: Colors.red))
                  // else
                  //   Text("Expires:"), Text(" ${widget.signal["expireAt"]}",
                  //       style:
                  //           const TextStyle(color: Colors.grey, fontSize: 11)),
                  
                  
                  // Text("Gain:"), Text(" ${widget.signal["gainLossPercentage"]}%",
                  //     style:
                  //         const TextStyle(color: Colors.green, fontSize: 19)),


