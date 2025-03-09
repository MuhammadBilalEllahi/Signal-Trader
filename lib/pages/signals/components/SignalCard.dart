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
  bool isFavorite = false;
  bool showFullAnalysis = false;

  @override
  void initState() {
    super.initState();
    isFavorite = widget.signal['isFavorite'] ?? false;
  }

  Future<void> toggleFavorite() async {
    final apiClient = ApiClient();
    final signalId = widget.signal["_id"];

    try {
      await apiClient.post("${ApiConstants.baseUrl}signals/favorite/$signalId", {});
      setState(() => isFavorite = !isFavorite);
    } catch (e) {
      debugPrint("❌ Error toggling favorite: $e");
    }
  }

  Widget _buildTypeTag(String type) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    LinearGradient getGradient() {
      switch (type.toLowerCase()) {
        case 'gold':
          return LinearGradient(
            colors: [
              Colors.yellow.shade700,
              Colors.amber.shade600,
              Colors.yellow.shade500,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );
        case 'crypto':
          return LinearGradient(
            colors: isDark ? [
              Colors.grey.shade700,
              Colors.grey.shade600,
              Colors.grey.shade500,
            ] : [
              Colors.grey.shade300,
              Colors.grey.shade400,
              Colors.grey.shade500,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );
        case 'stocks':
          return LinearGradient(
            colors: [
              Colors.black87,
              Colors.black54,
              Colors.black45,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );
        default:
          return LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.primary.withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );
      }
    }

    Color getTextColor() {
      switch (type.toLowerCase()) {
        case 'gold':
          return Colors.black87;
        case 'crypto':
          return isDark ? Colors.white : Colors.black87;
        case 'stocks':
          return Colors.white;
        default:
          return Theme.of(context).colorScheme.onPrimary;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
      margin: const EdgeInsets.only(left: 8),
      decoration: BoxDecoration(
        gradient: getGradient(),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        type.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: getTextColor(),
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    Widget cardContent = Column(
      // mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
            Expanded(
              child: Row(
                    children: [
                  if (widget.signal["type"] != "gold") 
                    Text(
                      widget.signal["coin"],
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                      ),
                    ),
                  _buildTypeTag(widget.signal["type"]),
                ],
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_outline,
                    color: isFavorite 
                        ? Theme.of(context).colorScheme.error
                        : Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                    size: 20,
                  ),
                  onPressed: toggleFavorite,
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        decoration: BoxDecoration(
                    color: widget.signal['direction'].toString().toLowerCase() == 'long'
                        ? Colors.green.withOpacity(isDark ? 0.1 : 0.05)
                        : Colors.red.withOpacity(isDark ? 0.1 : 0.05),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: widget.signal['direction'].toString().toLowerCase() == 'long'
                          ? Colors.green.withOpacity(0.3)
                          : Colors.red.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                          child: Text(
                    widget.signal['direction'],
                            style: TextStyle(
                      color: widget.signal['direction'].toString().toLowerCase() == 'long'
                          ? Colors.green.withOpacity(0.8)
                          : Colors.red.withOpacity(0.8),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                      ),
                    ],
                  ),
        const SizedBox(height: 16),
              Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
            color: isDark 
                ? Theme.of(context).colorScheme.surface.withOpacity(0.5)
                : Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
                  border: Border.all(
              color: Theme.of(context).dividerTheme.color ?? Colors.transparent,
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                  _buildInfoColumn(
                    icon: Icons.access_time,
                    label: "Date/Time",
                    value: widget.signal["createdFormatted"],
                  ),
                  _buildInfoColumn(
                    icon: Icons.account_balance_wallet,
                    label: "Portfolio %",
                    value: "${widget.signal["portfolioPercentage"]}%",
                    alignRight: true,
                                  ),
                                ],
                              ),
              const SizedBox(height: 16),
              Divider(
                color: Theme.of(context).dividerTheme.color?.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                  _buildPriceColumn(
                    icon: Icons.call_made,
                    label: "Entry Price",
                    value: "\$${widget.signal["entryPrice"]}",
                    isEntry: true,
                  ),
                  _buildPriceColumn(
                    icon: Icons.call_received,
                    label: "Exit Price",
                    value: "\$${widget.signal["exitPrice"]}",
                    isEntry: false,
                    alignRight: true,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
        if (widget.showAnalysis) ...[
          const SizedBox(height: 16),
          _buildAnalysisSection(),
        ],
      ],
    );

    return SizedBox(
      width: widget.showAnalysis ? MediaQuery.of(context).size.width : null,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        elevation: 0,
        color: isDark 
            ? Theme.of(context).colorScheme.surface
            : Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: Theme.of(context).dividerTheme.color ?? Colors.transparent,
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: cardContent,
        ),
      ),
    );
  }

  Widget _buildInfoColumn({
    required IconData icon,
    required String label,
    required String value,
    bool alignRight = false,
  }) {
    return Expanded(
                          child: Column(
        crossAxisAlignment: alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                            children: [
                              Row(
            mainAxisAlignment: alignRight ? MainAxisAlignment.end : MainAxisAlignment.start,
                                children: [
              Icon(
                icon,
                                    size: 16,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
    );
  }

  Widget _buildPriceColumn({
    required IconData icon,
    required String label,
    required String value,
    required bool isEntry,
    bool alignRight = false,
  }) {
    final color = isEntry ? Colors.green : Colors.red;
    
    return Expanded(
                          child: Column(
        crossAxisAlignment: alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                            children: [
                              Row(
            mainAxisAlignment: alignRight ? MainAxisAlignment.end : MainAxisAlignment.start,
                                children: [
              Icon(
                icon,
                                    size: 16,
                color: color.withOpacity(0.8),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: color,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
    );
  }

  Widget _buildAnalysisSection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
        color: isDark 
            ? Theme.of(context).colorScheme.surface.withOpacity(0.5)
            : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
                  border: Border.all(
          color: Theme.of(context).dividerTheme.color ?? Colors.transparent,
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
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                          ),
                          child: Icon(
                            Icons.analytics_outlined,
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.8),
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Analysis',
                          style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    LayoutBuilder(
                      builder: (context, constraints) {
              final text = widget.signal["hasTradingAnalysis"] 
                  ? widget.signal["tradingAnalysis"] 
                  : "No analysis available for this signal.";
                        
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              text,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                height: 1.5,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                              ),
                              maxLines: showFullAnalysis ? null : 6,
                              overflow: TextOverflow.fade,
                            ),
                  if (text.length > 300)
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SignalDetailedPage(signal: widget.signal),
                                    ),
                                  );
                                },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                                child: Text(
                        'Show more...',
                                  style: TextStyle(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.8),
                                    fontSize: 12,
                          fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ],
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


