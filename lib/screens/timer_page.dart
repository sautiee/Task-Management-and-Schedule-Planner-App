import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:taskmanagement/data/database.dart';
import 'package:taskmanagement/widgets/task_dialog_box.dart';
import 'package:taskmanagement/widgets/timer_dialog_box.dart';
//import 'package:taskmanagement/constants/colors.dart';

class TimerPage extends StatefulWidget {
  const TimerPage({super.key});

  @override
  State<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> {
  
  Duration duration = Duration(minutes: 25);

  late int timeLeft;

  final _box1 = Hive.box('box1');
  TaskDatabase db = TaskDatabase();
  String? selectedTask;

  @override
  void initState() {
    if (_box1.get("TASKLIST") == null){
      db.createInitialData();
    }
    else {
      db.loadData();
    }

    super.initState();
    timeLeft = duration.inSeconds;
  }


  Timer? timer;

  void showTimerPicker() async {
    final selectedDuration = await showDialog<Duration>(
    context: context,
    builder: (context) => TimerDialogBox(),
  );

  if (selectedDuration != null) {
    setState(() {
      duration = selectedDuration;
      timeLeft = selectedDuration.inSeconds;
    });
  }
}


  void startTimer({bool reset = true}) {
    if (reset) {
      resetTimer();
    }

    setState(() {
      if (timeLeft > 0) {
        timeLeft--; //start timer immediately (no delay)
      }
      else {
        stopTimer(reset: false);
        return;
      }
    });

    timer = Timer.periodic(Duration(seconds: 1), (_) {
      setState(() {
        if (timeLeft > 0) {
          timeLeft--;
        }
        else {
          stopTimer(reset: false);
        }
      });
    });
  }

  void resetTimer() {
    setState(() {
      timeLeft = duration.inSeconds;
    });
  }


  void stopTimer({bool reset = true}) {
    if (reset) {
      resetTimer();
    }
    
    setState(() => timer?.cancel());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
        body: Container(
          child:
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 50),
                  child: SizedBox(
                    child: MaterialButton(
                      onPressed: () {
                        showModalBottomSheet(
                          backgroundColor: Theme.of(context).colorScheme.surface,
                          context: context,
                          builder: (context) => TaskDialogBox(
                            taskList: db.taskList,
                            onTaskSelected: (taskName) {
                              setState(() {
                                selectedTask = taskName;
                              });
                            },
                          ),
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            selectedTask == null ? 'Choose Task' : selectedTask!,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                          Icon(Icons.arrow_right_sharp, color: Theme.of(context).colorScheme.onSurfaceVariant,)
                        ],
                      ),
                      ),
                    ),
                  ),
                  buildTimer(),
                  const SizedBox(height: 80),
                  buildButtons(),
                  ],
                ),
            ),
        );
  }

  Widget buildButtons() {
    //determine if timer is currently active
    final isRunning = timer == null ? false : timer!.isActive;
    final isCompleted = timeLeft == duration.inSeconds || timeLeft == 0;

    return isRunning || !isCompleted
            ? Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  MaterialButton(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    color: Theme.of(context).colorScheme.primary,
                    onPressed: () {
                      
                      if (isRunning) {
                        stopTimer(reset: false);
                      }
                      else {
                        startTimer(reset: false);
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        //check if timer is paused or not
                        isRunning ? 'Pause' : 'Resume',
                        style: TextStyle(fontSize: 15, color: Theme.of(context).colorScheme.onPrimary),
                      ),
                    ),
                  ),

                     MaterialButton(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      onPressed: stopTimer,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          "Cancel",
                          style: TextStyle(fontSize: 15, color: Theme.of(context).colorScheme.onSurfaceVariant),
                        ),
                      ),
                    ),
                ],
              ),
            )
              
      : Center(
          child: MaterialButton(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
            onPressed: startTimer,
            color: Theme.of(context).colorScheme.primary,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Start",
                style: TextStyle(
                  fontSize: 15,
                  color: Theme.of(context).colorScheme.onPrimary
                  ),
                ),
            ),
        ),
      );
  }

  Widget buildTimer() => SizedBox(
  width: 300,
  height: 300,
  child: Stack(
    fit: StackFit.expand,
    children: [
      //make animation smoother
      TweenAnimationBuilder<double>(
        tween: Tween<double>(
          begin: 0,
          end: 1 - timeLeft / duration.inSeconds,
        ),
        duration: Duration(seconds: 1), // controls smoothness
        builder: (context, value, _) => CircularProgressIndicator(
          value: value,
          strokeWidth: 6,
          backgroundColor: Theme.of(context).colorScheme.surfaceTint,
          valueColor: AlwaysStoppedAnimation(Theme.of(context).colorScheme.primary),
        ),
      ),
      Center(child: GestureDetector(
        onTap: () {
          showTimerPicker();
        },
        child: buildTime(),
      )
      ),
    ],
  ),
);


Widget buildTime() {
  if (timeLeft == 0) {
    return Icon(Icons.done, color: Theme.of(context).colorScheme.primary, size: 112);
  } else {
    //display minutes and seconds
    final minutes = (timeLeft ~/ 60).toString().padLeft(2, '0'); //integer division, padleft makes timer look like this 00:00
    final seconds = (timeLeft % 60).toString().padLeft(2, '0');

    return Text(
      '$minutes:$seconds',
      style: TextStyle(
        fontSize: 50,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

Widget buildTimePicker() => SizedBox(
  height: 180,
  child: CupertinoTimerPicker(
    initialTimerDuration: duration,
    mode: CupertinoTimerPickerMode.hm,
    onTimerDurationChanged: (duration) =>
    setState(() {
      this.duration = duration;
    }),
  ),
);

}