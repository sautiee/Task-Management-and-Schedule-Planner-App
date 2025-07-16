import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TimerDialogBox extends StatefulWidget {
  TimerDialogBox({super.key});

  @override
  State<TimerDialogBox> createState() => _TimerDialogBoxState();
}

class _TimerDialogBoxState extends State<TimerDialogBox> {
  Duration duration = Duration(minutes: 25);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      backgroundColor: Theme.of(context).colorScheme.surface,
      content: SizedBox(
        height: 220,
        width: 300,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              "Select your timer:",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            SizedBox(
              height: 100,
              child: CupertinoTimerPicker(
                initialTimerDuration: duration,
                mode: CupertinoTimerPickerMode.hm,
                onTimerDurationChanged: (newDuration) {
                  setState(() {
                    duration = newDuration; //set to new duration
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MaterialButton(
                    color: Theme.of(context).colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)
                    ),
                    child: Text('OK'),
                    onPressed: () {
                      Navigator.of(context).pop(duration); // return new duration and dismiss dialog
                    },
                  ),
                  SizedBox(width: 10),
                  MaterialButton(
                    color: Theme.of(context).colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)
                    ),
                    child: Text('Cancel'),
                    onPressed: () {
                      Navigator.pop(context); // dismiss dialog
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
