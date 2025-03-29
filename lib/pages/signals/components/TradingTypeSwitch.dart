import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tradingapp/providers/subscription_provider.dart';
import '../subscription/FuturesSubscription.dart';

class TradingTypeSwitch extends StatelessWidget {
  final bool isSpotSelected;
  final Function(bool) onSpotSelected;

  const TradingTypeSwitch({
    super.key,
    required this.isSpotSelected,
    required this.onSpotSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subscriptionProvider = Provider.of<SubscriptionProvider>(context);
    final hasFuturesAccess = subscriptionProvider.isSubscribed;

    return Container(
      height: 36,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: isDark 
            ? Theme.of(context).colorScheme.surface
            : Theme.of(context).colorScheme.surface.withOpacity(0.8),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).dividerTheme.color ?? Colors.transparent,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildOption(
            context,
            label: 'Spot',
            isSelected: isSpotSelected,
            onTap: () => onSpotSelected(true),
          ),
          _buildOption(
            context,
            label: 'Futures',
            isSelected: !isSpotSelected,
            onTap: () {
              if (!hasFuturesAccess) {
                showDialog(
                  context: context,
                  builder: (context) => const FuturesSubscriptionPage(),
                );
                return;
              }
              onSpotSelected(false);
            },
            isLocked: !hasFuturesAccess,
          ),
        ],
      ),
    );
  }

  Widget _buildOption(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    bool isLocked = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
            if (isLocked) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.lock,
                size: 14,
                color: isSelected
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
              ),
            ],
          ],
        ),
      ),
    );
  }
} 