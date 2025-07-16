import 'package:flutter/material.dart';

class TaskDialogBox extends StatefulWidget {
  final List taskList;
  final Function(String taskName) onTaskSelected;

  TaskDialogBox({
    super.key,
    required this.taskList, 
    required this.onTaskSelected
    }
  );

  @override
  State<TaskDialogBox> createState() => _TaskDialogBoxState();
}

class _TaskDialogBoxState extends State<TaskDialogBox> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      content: SizedBox(
        height: 500,
        width: 300,
        child: ListView.separated(
          itemCount: widget.taskList.where((task) => task[1] == false).length, //only fetch uncompleted tasks
            itemBuilder: (context, index) {
              final uncompletedTask = widget.taskList.where((task) => task[1] == false).toList();
              final taskName = uncompletedTask[index][0];

              return ListTile(
                title: Text(
                  taskName,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w500
                  )
                ),
                leading: Icon(Icons.add),
                onTap: () {
                  widget.onTaskSelected(taskName);
                  Navigator.pop(context);
                },
              );
            },
            separatorBuilder: (context, index) => Divider(
              color: const Color.fromARGB(255, 170, 196, 226),
              thickness: 1,
              height: 0,
            ),
          ),
      ),
    );
  }
}