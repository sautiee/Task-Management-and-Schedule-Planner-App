import 'package:flutter/material.dart';

class StoreItemCard extends StatelessWidget {
  final String themeName;
  final String themePrice;
  final String imagePath;
  final bool isBought;
  final bool isSelected;
  final VoidCallback onBuy;
  final VoidCallback onUse;

  const StoreItemCard({
    super.key,
    required this.themeName,
    required this.themePrice,
    required this.imagePath,
    required this.isBought,
    required this.isSelected,
    required this.onBuy,
    required this.onUse,
  });

  @override
Widget build(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.only(top: 16), // slightly less top padding
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: isSelected
            ? Theme.of(context).colorScheme.primary.withOpacity(0.18)
            : Theme.of(context).colorScheme.secondary,
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? Theme.of(context).colorScheme.primary.withOpacity(0.02)
                : Colors.black.withOpacity(0.07),
            blurRadius: isSelected ? 16 : 8,
            offset: const Offset(0, 6),
          ),
        ],
        border: isSelected
            ? Border.all(
                color: Theme.of(context).colorScheme.primary,
                width: 2.2,
              )
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Image
          Padding(
            padding: const EdgeInsets.only(top: 14.0, bottom: 0),
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Image.asset(
                imagePath,
                width: 55,
                height: 55,
                fit: BoxFit.contain,
              ),
            ),
          ),

          // Name
          Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 2),
            child: Text(
              themeName,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurface,
                letterSpacing: 0.5,
              ),
            ),
          ),

          // Price or "In Use"/"Use" Button
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
            child: MaterialButton(
              minWidth: double.minPositive,
              height: 36, // slightly less height
              color: isBought
                  ? (isSelected
                      ? Colors.green.shade400
                      : Theme.of(context).colorScheme.primary)
                  : Colors.amber.shade400,
              elevation: isSelected ? 2 : 0.5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              onPressed: isBought ? onUse : onBuy,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!isBought)
                    const Icon(Icons.attach_money_rounded, color: Colors.brown, size: 20),
                  if (!isBought) const SizedBox(width: 2),
                  Text(
                    isBought
                        ? (isSelected ? "In Use" : "Use")
                        : themePrice,
                    style: TextStyle(
                      color: isBought
                          ? Theme.of(context).colorScheme.onPrimary
                          : Colors.brown[900],
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      letterSpacing: 0.2,
                    ),
                  ),
                  if (isBought && isSelected)
                    const Padding(
                      padding: EdgeInsets.only(left: 6),
                      child: Icon(Icons.check_circle, color: Colors.white, size: 16),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 4), // less bottom space
        ],
      ),
    ),
  );
}
}