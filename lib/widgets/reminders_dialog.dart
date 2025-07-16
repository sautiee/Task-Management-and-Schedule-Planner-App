import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RemindersDialog extends StatefulWidget {
  final int initialNumber;
  final int initialUnitIndex;
  final List<String> timeUnits;
  final List<int> Function(String) getNumberRangeForUnit;

  const RemindersDialog({
    super.key,
    required this.initialNumber,
    required this.initialUnitIndex,
    required this.timeUnits,
    required this.getNumberRangeForUnit,
  });

  @override
  State<RemindersDialog> createState() => _RemindersDialogState();
}

class _RemindersDialogState extends State<RemindersDialog> {
  late int selectedNumber;
  late int selectedUnitIndex;

  @override
  void initState() {
    super.initState();
    selectedNumber = widget.initialNumber;
    selectedUnitIndex = widget.initialUnitIndex;
  }

  @override
  Widget build(BuildContext context) {
    List<int> currentNumbers =
        widget.getNumberRangeForUnit(widget.timeUnits[selectedUnitIndex]);

    // Make sure selectedNumber is valid if unit changed externally
    if (selectedNumber > currentNumbers.length) {
      selectedNumber = currentNumbers.last;
    }

    return AlertDialog(
      title: Text('Select Reminder'),
      content: SizedBox(
        height: 180,
        child: Row(
          children: [
            Expanded(
              child: CupertinoPicker(
                itemExtent: 50,
                scrollController: FixedExtentScrollController(
                  initialItem: selectedNumber - 1,
                ),
                onSelectedItemChanged: (index) {
                  setState(() {
                    selectedNumber = currentNumbers[index];
                  });
                },
                children:
                    currentNumbers.map((num) => Center(child: Text('$num'))).toList(),
              ),
            ),
            Expanded(
              child: CupertinoPicker(
                itemExtent: 40,
                scrollController: FixedExtentScrollController(
                  initialItem: selectedUnitIndex,
                ),
                onSelectedItemChanged: (index) {
                  setState(() {
                    selectedUnitIndex = index;

                    // Validate number on unit change
                    List<int> newRange =
                        widget.getNumberRangeForUnit(widget.timeUnits[index]);
                    if (selectedNumber > newRange.length) {
                      selectedNumber = newRange.last;
                    }
                  });
                },
                children: widget.timeUnits
                    .map((unit) => Center(child: Text(unit)))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel')),
        TextButton(
            onPressed: () => Navigator.of(context).pop({
                  'number': selectedNumber,
                  'unitIndex': selectedUnitIndex,
                }),
            child: Text('OK')),
      ],
    );
  }
}
