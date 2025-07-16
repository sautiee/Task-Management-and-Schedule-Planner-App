import 'package:flutter/material.dart';

class StatisticsTile extends StatefulWidget {
  final String? label;
  final String? imagePath;
  final IconData? icon;
  final String? value;
  final Color? color;

  const StatisticsTile({
    super.key,
    required this.label,
    required this.icon,
    required this.value,
    this.color,
    this.imagePath,
  });

  @override
  State<StatisticsTile> createState() => _StatisticsTileState();
}

class _StatisticsTileState extends State<StatisticsTile> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            
            // Show image if imagePath is provided, else show icon
            if (widget.imagePath != null)
              Image.asset(
                widget.imagePath!,
                width: 43,
                height: 43,
                fit: BoxFit.contain,
              )
            else
              Icon(
                widget.icon ?? Icons.info,
                size: 43,
                color: widget.color ?? Theme.of(context).colorScheme.onSecondary,
              ),
      
            const SizedBox(height: 10),
            
            Text(
              widget.value ?? "No Value",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
      
            Text(
              widget.label ?? "No Label",
              textAlign: TextAlign.start,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            
          ],
        ),
      ),
    );
  }
}